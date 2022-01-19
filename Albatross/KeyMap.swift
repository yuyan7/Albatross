//
//  KeyMap.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/20.
//

import Foundation


enum ConfigError: Error {
    case openFail
    case createFail
    case invalidJSON(String)
    case invalidValue(String)
}

class KeyMap: NSObject {
    private var map: [Int: Array<Any>] = [:]
    private let configPath = URL(string: "\(FileManager.default.homeDirectoryForCurrentUser).albatrossrc")!
    private var fd: Int32 = -1
    private var source: DispatchSourceFileSystemObject? = nil


    override init() {
        super.init()
    }
    
    deinit {
        print("deinit")
        if let s = source {
            s.cancel()
            source = nil
        }
        if fd < 0 {
            close(fd)
            fd = -1
        }
    }
    
    public func loadConfig() throws {
        if !FileManager.default.fileExists(atPath: configPath.path) {
            print("File not found, create it")
            if !FileManager.default.createFile(
                atPath: configPath.path,
                contents: "{\"50\":[\"B\"]}".data(using: .utf8),
                attributes: [
                    FileAttributeKey.posixPermissions: 0o644
                ]) {
                throw ConfigError.createFail
            }
        }
        if let fp = FileHandle(forReadingAtPath: configPath.path) {
            let content = fp.readDataToEndOfFile()
            var config: [String: Array<String>]
            do {
                config = try JSONDecoder().decode([String: Array<String>].self, from: content)
            } catch {
                throw ConfigError.invalidJSON("Invalid JSON Format")
            }
            do {
                try toMap(config: config)
            } catch {
                throw error
            }

        } else {
            throw ConfigError.openFail
        }
    }
    
    private func toMap(config: [String: Array<String>]) throws {
        for (key, val) in config {
            print("\(key) is \(val)")
        }
        //throw ConfigError.invalidValue("Unexpected setting")
    }
    
    public func watchConfig() {
        print("watch start: \(configPath.path)")
        let queue = DispatchQueue.global(qos: .default)
        
        let fd = open(configPath.path, O_EVTONLY)
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .rename, queue: queue)
        source.setEventHandler(handler: { () -> Void in
            print("File changed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                try? self.loadConfig()
            }
        })
        source.activate()
        self.fd = fd
        self.source = source
    }

}
