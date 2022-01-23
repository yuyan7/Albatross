//
//  KeyAlias.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import AppKit

class KeyAlias: NSObject {
    private var config: AppConfig
    private var currentApp: String = ""
    private var aliases: Dictionary<Int64, [SourceEvent]> = [:]
    
    init(config: AppConfig) {
        self.config = config
        super.init()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleActiveApplicationChange), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }
    
    @objc func handleActiveApplicationChange(_ notification: NSNotification) {
        if let app = notification.userInfo?["NSWorkspaceApplicationKey"] as? NSRunningApplication {
            if let appName = app.localizedName {
                self.currentApp = appName
                self.updateAlias()
            }
        }
    }
    
    public func updateConfig(config: AppConfig) {
        self.config = config
        self.updateAlias()
    }
    
    private func updateAlias() {
        var aliases: Dictionary<Int64, [SourceEvent]> = [:]
        
        for a in config.getAppAliases(appName: currentApp) {
            if let evt = createRemapEvent(alias: a) {
                if var v = aliases[evt.getKeyCode()] {
                    v.append(evt)
                } else {
                    aliases[evt.getKeyCode()] = [evt]
                }
            }
        }
        
        self.aliases = aliases
    }
}
