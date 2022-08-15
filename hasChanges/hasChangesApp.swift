//
//  hasChangesApp.swift
//  hasChanges
//
//  Created by Kyrylo Onyshchuk on 15.08.2022.
//

import SwiftUI

@main
struct hasChangesApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
