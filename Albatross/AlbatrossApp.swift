//
//  AlbatrossApp.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/18.
//

import SwiftUI

@main
struct AlbatrossApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
