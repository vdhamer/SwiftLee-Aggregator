//
//  SwiftLeeAggregatorApp.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import SwiftUI

@main
struct SwiftLeeAggregatorApp: App {
    var body: some Scene {
        WindowGroup {
            PostListView(blogPosts: [Post]()) // start with an empty array
        }
    }
}
