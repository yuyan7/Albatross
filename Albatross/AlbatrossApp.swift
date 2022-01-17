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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
