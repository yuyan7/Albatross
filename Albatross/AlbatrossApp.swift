//
//  AlbatrossApp.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/18.
//

import SwiftUI

func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items[0], separator: separator, terminator: terminator)
    #endif
}

@main
struct AlbatrossApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

