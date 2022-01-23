//
//  AppDelegate.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/22.
//

import Cocoa


var statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let keyboardObserver: KeyboardObserver
    let keyRemapper: KeyRemapper
    let keyAlias: KeyAlias
    let appConfig = AppConfig()
    
    override init() {
        keyRemapper = KeyRemapper()
        keyAlias = KeyAlias(config: appConfig)
        keyboardObserver = KeyboardObserver(alias: keyAlias)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        if let button = statusItem.button {
            button.title = "H"
            button.highlight(false)
        }
        statusItem.menu = menu
        menu.addItem(withTitle: "Edit Remap", action: #selector(AppDelegate.config(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")

        do {
            try appConfig.load()
        } catch ConfigError.invalid(let message) {
            let alert = AppAlert(message: "Configuration is invalid", information: message)
            alert.display()
        } catch {
            let alert = AppAlert(message: "Unexpected process error", information: error.localizedDescription)
            alert.display()
            NSApplication.shared.terminate(self)
        }
        
        appConfig.watch() { config in 
            self.keyRemapper.updateConfig(config: config)
            self.keyAlias.updateConfig(config: config)
        }
        
        // Initialize
        keyRemapper.updateConfig(config: appConfig)
        keyAlias.updateConfig(config: appConfig)
        
        keyboardObserver.start()
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func config(_ sender: NSButton) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(appConfig.getFilePath(), forType: .string)
        let notification = AppNotification(body: "Copied Configuration file path.\nModify configuration with your favorite editor")
        notification.display()
    }

    
    func applicationWillTerminate(_ notification: Notification) {
        print("WillTerminate")
        
        // we MUST restore default keymaps
        keyRemapper.restore()
    }
}
