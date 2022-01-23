//
//  AppConfig.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import Yams

let configPath = URL(string: NSHomeDirectory() + "/albatrosconfig.yaml")!

struct Config: Codable {
    let remaps: Dictionary<String, String>
    let globalAliases: [Alias]
    let appAliases: [AppAlias]
    
    init() {
        remaps = [:]
        globalAliases = []
        appAliases = []
    }
}

struct Alias: Codable {
    let from: [String]
    let to: [String]
    
    init() {
        from = []
        to = []
    }
}

struct AppAlias: Codable {
    let app: String
    let aliases: [Alias]
    
    init() {
        app = ""
        aliases = []
    }
}

enum ConfigError: Error {
    case openFail
    case createFail
    case invalid(String)
}

class AppConfig: NSObject {
    private let filePath: URL
    private var config: Config
    private var fd: CInt?
    private var sources: [DispatchSourceFileSystemObject] = []
    private var subscribers: [(AppConfig) -> Void] = []
    
    override init() {
        self.config = Config()
        
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.filePath = document.appendingPathComponent("config/albatross.yml", isDirectory: false)
    }
    
    private func cancel() {
        print("close")
        for source in sources {
            source.cancel()
        }
        if let fd = self.fd {
            close(fd)
        }
        sources = []
        fd = nil
    }
    
    public func subscribe(callback: @escaping (AppConfig) -> Void) {
        subscribers.append(callback)
    }
    
    public func getFilePath() -> String {
        return filePath.path
    }
    
    public func getRemap() -> Dictionary<String, String> {
        return config.remaps
    }

    public func getAppAliases(appName: String) -> [Alias] {
        var aliases: [Alias] = []
        for a in config.globalAliases {
            aliases.append(a)
        }
        
        for app in config.appAliases {
            if app.app != appName {
                continue
            }
            for a in app.aliases {
                aliases.append(a)
            }
        }
        return aliases
    }
    
    public func load() throws {
        if !checkConfigFile() {
            throw ConfigError.createFail
        }
       
        if let fp = FileHandle(forReadingAtPath: filePath.path) {
            let decoder = YAMLDecoder()
            do {
                let content = fp.readDataToEndOfFile()
                let decoded = try decoder.decode(Config.self, from: content)
                config = decoded
            } catch {
                throw ConfigError.invalid("Invalid Config" + error.localizedDescription)
            }
        } else {
            throw ConfigError.openFail
        }
    }
    
    public func watch(callback: @escaping (AppConfig) -> Void) {
        self.cancel()
        print("watch start: \(filePath.path)")
        let queue = DispatchQueue.global(qos: .default)
            
        let fd = open(filePath.path, O_EVTONLY)
        
        // We need to monitor multiple file change events, .write and .rename because:
        // on Vim, file editing is processed with move (using swap file) so rename event will be fired
        // on other editor (e.g Visual Studio Code), simply write so write event will be fired
        for event in [DispatchSource.FileSystemEvent.write, DispatchSource.FileSystemEvent.rename] {
            let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: event, queue: queue)
            source.setEventHandler(handler: { () -> Void in
                print("event fired for \(event)")
                // Need a bit delay to reload config after file change event finished
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    do {
                        try self.load()
                        callback(self)
                        self.watch(callback: callback)
                    } catch {
                        let notification = AppNotification(body: "Configuration did not update because invalid setting")
                        notification.display()
                    }
                    
                }
            })
            source.activate()
            self.sources.append(source)
        }
       
        self.fd = fd
    }
    
    private func checkConfigFile() -> Bool {
        if FileManager.default.fileExists(atPath: filePath.path) {
            return true
        }
        
        print("File not found, create it")
        
        guard let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let configDir = document.appendingPathComponent("config", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }

        return FileManager.default.createFile(
            atPath: filePath.path,
            contents: configurationTemplate.data(using: .utf8),
            attributes: [
                FileAttributeKey.posixPermissions: 0o644
            ])
    }
}

let configurationTemplate = """
###
### Albatross key remap configuration file
###

# In this app, meta keys define string constant as below:
#
# Esc: Escape
# Tab: Tab
# Command_L: Command Left
# Command_R: Command Right
# Del: Delete
# Ins: Insert
# Return: Return (Enter)
# Up: Up Arrow
# Right: Right Arrow
# Down: Down Arrow
# Left: Left Arrow
# Alphabet: Special Key, switch input mode to alphabet
# Kana: Special Key, switch input mode to kana
# F1: F1
# F2: F2
# F3: F3
# F4: F4
# F5: F5
# F6: F6
# F7: F7
# F8: F8
# F9: F9
# F10: F10
# F11: F11
# F12: F12
# Shift_L: Shift Left
# Shift_R: Shift Right
# Option_L: Option Left
# Option_R: Option Right
# CapsLock: Caps Lock
# Space: Space
#
# We do not support special meta keys like Vol up, Vol down, etc.

# "remaps" field specifies physical key mapping using IOKit, value shold be [src]: [dest] format.
# Key name is case insensitive (e.g "a" and "A" indicates the same key).
#
# For example:
# ```
# remaps:
#   a: b  <- "a" key maps to "b"
# ```
#
# Note that this setting is enable globally, all keyboard inputs always remaps for your setting.
# All keys spec is described at https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
remaps: {}

# "globalAliases" field specifies alias mapping using CGEvent, simply specify keyboard alias globally.
#
# Importants
#  * In this setting, key name is case sensitive. For example, CGEvent distiguishes "a" and "A" (differences shift key is pressed or not).
#
# For example
# ```
# globalAliases:
#   - from: [Ctrl, a]    <- alias from Control + a
#     to: [Command_L, a] <- alias to Command + a
# ```
#
# Above setting set alias mapping from "Ctrl+a" to "Command+a".
#
globalAliases: []

# "appAliases" field specifies alias mapping using CGEvent, specify keyboard alias correspond to the application.
# You can list applications which you want to use alias.
#
# Importants
#  * app name is actual process name which is defined app.localizedName. It it hard to find, but you may find via Activity Monitor app.
#  * In this setting, key name is case sensitive. For example, CGEvent distiguishes "a" and "A" (differences shift key is pressed or not).
#
# For example
# ```
# appAliases:
#  - app: "Google Chrome"   <- enable alias only for Google Chrome (must be an app.localizedName)
#    aliaes:
#      - from: [Ctrl, a]
#        to: [Command_L, a]
#
# Above setting set alias mapping from "Ctrl+a" to "Command+a", will work as select all page by pressing "Ctrl+a" keys.
#
appAliases: []
"""
