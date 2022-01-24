//
//  AlbatrossLaunchAtLoginApp.swift
//  AlbatrossLaunchAtLogin
//
//  Created by Yoshiaki Sugimoto on 2022/01/25.
//

import SwiftUI

@main
struct AlbatrossLaunchAtLoginApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
