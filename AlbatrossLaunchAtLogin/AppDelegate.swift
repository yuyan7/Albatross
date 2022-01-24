//
//  AppDelegate.swift
//  AlbatrossLaunchAtLogin
//
//  Created by Yoshiaki Sugimoto on 2022/01/25.
//

import Foundation
import AppKit

let MAIN_APP_IDENTIFER = "io.github.ysugimoto.Albatross"

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // ref: https://questbeat.hatenablog.jp/entry/2014/04/19/123207
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        var running = false
        var active = false
        
        let applications = NSRunningApplication.runningApplications(withBundleIdentifier: MAIN_APP_IDENTIFER)
        if let app = applications.first {
            running = true
            active = app.isActive
        }
        
        if !running && !active {
            if let appUrl = URL(string: String(format: "%s://", MAIN_APP_IDENTIFER)) {
                NSWorkspace.shared.open(appUrl)
            }
        }
        
        NSApp.terminate(nil)
    }

}
