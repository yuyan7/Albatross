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
    let keymap = KeyMap()

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
    
    init() {
        do {
            try keymap.loadConfig()
        } catch ConfigError.invalidJSON(let message) {
            print(message)
            exit(1)
        } catch ConfigError.invalidValue(let message) {
            print(message)
            exit(1)
        } catch {
            print(error)
            exit(1)
        }
        keymap.watchConfig()
        observer.start()
    }
}
