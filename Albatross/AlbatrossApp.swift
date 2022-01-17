//
//  AlbatrossApp.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/18.
//

import SwiftUI

@main
struct AlbatrossApp: App {
    let persistenceController = PersistenceController.shared
    let observer = KeyboardObserver()

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
    
    init() {
        observer.start()
    }
}
