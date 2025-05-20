//
//  DexApp.swift
//  Dex
//
//  Created by Juan Camilo Victoria Pacheco on 20/05/25.
//

import SwiftUI

@main
struct DexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
