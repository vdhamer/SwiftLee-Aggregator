//
//  SwiftLeeAggregatorApp.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import SwiftUI
import CoreData

@main
struct SwiftLeeAggregatorApp: App {
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-configure-core-data-to-work-with-swiftui

    @Environment(\.scenePhase) var scenePhase
    private let persistenceController = PersistenceController.shared
    private let swiftLeeDebugMode = false

    init() {
        let viewContext = persistenceController.container.viewContext
        // SwiftLee sometimes updates an article. The title and shortURL stay the same but publication date changes
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // was .overwrite
        if swiftLeeDebugMode {
            print("Running with debug in SwilftLeeAggregatorApp.swift set to \(swiftLeeDebugMode)")
        }
    }

    var body: some Scene {
        WindowGroup {
            PostListView(swiftLeeDebugModePayloadString: swiftLeeDebugMode ?
                         PostListView_Previews.hardcodedJsonString : nil)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save() // when app moves to background
        }
    }
}
