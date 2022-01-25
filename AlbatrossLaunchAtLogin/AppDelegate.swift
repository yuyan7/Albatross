//
//  AppDelegate.swift
//  AlbatrossLaunchAtLogin
//
//  Created by Yoshiaki Sugimoto on 2022/01/25.
//

import Foundation
import AppKit

let mainAppIdentifier = "io.github.ysugimoto.Albatross"

class AppDelegate: NSObject, NSApplicationDelegate {

    // ref: https://questbeat.hatenablog.jp/entry/2014/04/19/123207
    func applicationDidFinishLaunching(_ notification: Notification) {
        var running = false
        var active = false
        
        let applications = NSRunningApplication.runningApplications(withBundleIdentifier: mainAppIdentifier)
        if let app = applications.first {
            running = true
            active = app.isActive
        }
        
        if !running && !active {
            if let appUrl = URL(string: String(format: "%s://", mainAppIdentifier)) {
                NSWorkspace.shared.open(appUrl)
            }
        }
        
        NSApp.terminate(nil)
    }

}
