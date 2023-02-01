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
    let persistenceController = PersistenceController.shared
    let debug: Bool

    init() {
        let viewContext = persistenceController.container.viewContext
        // SwiftLee apparently sometimes updates an artible: title and shortURL stay the same, publication date changes
        viewContext.mergePolicy = NSMergePolicy.overwrite
        debug = true
        print("Running with debug in SwilftLeeAggregatorApp.swift set to \(debug)")
    }

    var body: some Scene {
        WindowGroup {
            PostListView(testString: debug ? PostListView_Previews.hardcodedJsonString : nil,
                         predicate: NSPredicate.all)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save() // when app moves to background
        }
    }
}
