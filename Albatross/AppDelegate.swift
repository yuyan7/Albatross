//
//  AppDelegate.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/22.
//

import Cocoa


var statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let keyboardObserver: KeyboardObserver
    private let keyRemapper: KeyRemapper
    private let keyAlias: KeyAlias
    private let appConfig = AppConfig()
    private let menu: NSMenu = NSMenu()
    private var isPauseRemap = false
    
    override init() {
        keyRemapper = KeyRemapper()
        keyAlias = KeyAlias(config: appConfig)
        keyboardObserver = KeyboardObserver(alias: keyAlias)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = statusItem.button {
            //button.title = "H"
            button.image = NSImage(named: NSImage.Name("AppIcon-Mono"))
            button.highlight(false)
        }
        statusItem.menu = menu
        menu.addItem(withTitle: "Edit Remap", action: #selector(AppDelegate.config(_:)), keyEquivalent: "")
        menu.addItem(withTitle: isPauseRemap ? "✓ Pause Remap" : "Pause Remap", action: #selector(AppDelegate.pause(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Albatross", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")
        
        AppTrusted.isTrusted {
            do {
                try self.appConfig.load()
            } catch ConfigError.invalid(let message) {
                AppAlert.display(message: "Configuration is invalid", information: message)
            } catch {
                AppAlert.display(message: "Unexpected process error", information: error.localizedDescription)
                NSApplication.shared.terminate(self)
            }
            
            self.appConfig.watch() { config in
                self.keyRemapper.updateConfig(config: config)
                self.keyAlias.updateConfig(config: config)
            }
            
            // Initialize
            self.keyRemapper.updateConfig(config: self.appConfig)
            self.keyAlias.updateConfig(config: self.appConfig)
            
            do {
                try self.keyboardObserver.start()
            } catch {
                AppAlert.display(message: "Appication boot faild", information: "Failed to observer keyboard input event")
                NSApplication.shared.terminate(self)
            }
        }
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func config(_ sender: NSButton) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(appConfig.getFilePath(), forType: .string)
        AppNotification.display(body: "Copied Configuration file path.\nModify configuration with your favorite editor")
    }
    
    @IBAction func pause(_ sender: NSButton) {
        isPauseRemap = !isPauseRemap
        
        // pause remap/alias if flag turns on
        isPauseRemap ? keyRemapper.pause() : keyRemapper.resume(config: appConfig)
        isPauseRemap ? keyboardObserver.pause() : keyboardObserver.resume()

        menu.removeItem(at: 1)
        let pauseText = isPauseRemap ? "✓ Pausing Remap" : "Pause Remap"
        menu.insertItem(withTitle: pauseText, action: #selector(AppDelegate.pause(_:)), keyEquivalent: "", at: 1)

        AppNotification.display(body: isPauseRemap ? "KeyRemap is paused" : "KeyRemap is resumed")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // we MUST restore default keymaps on application terminating
        keyRemapper.restore()
    }
}
