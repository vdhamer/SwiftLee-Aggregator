//
//  RSSFeed.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import Foundation

struct Page: Decodable, Identifiable {

    enum CodingKeys: String, CodingKey, Hashable {
        case status
        case feed
        case postings = "items"
    }

    let status: String
    let feed: WrappedPosting
    let postings: [Posting]

    var id: URL {
        feed.url
    }
}
