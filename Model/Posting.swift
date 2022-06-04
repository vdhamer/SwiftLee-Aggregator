//
//  Posting.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import Foundation

struct WrappedPosting: Decodable, Identifiable {

    enum CodingKeys: String, CodingKey, Hashable {
        case url
        case title
        case urlBase = "link"
        case author
        case description
        // swiftlint:disable:next identifier_name
        case _imageUrlString = "image"
    }

    let url: URL
    let title: String
    let urlBase: URL
    let author: String
    let description: String
    // swiftlint:disable:next identifier_name
    let _imageUrlString: String // can be URL or empty string

    var id: URL { url }
    var imageURL: URL? { URL(string: _imageUrlString) }
}

struct Posting: Decodable, Identifiable {

    enum CodingKeys: String, CodingKey, Hashable {
        case title
        case pubDate
        case url = "link"
        case shortURL = "guid"
        case author
        // swiftlint:disable:next identifier_name
        case _thumbNailUrlString = "thumbnail"
        case description
        case keywords = "categories"
    }

    let title: String
    let pubDate: Date
    let url: URL
    var shortURL: URL?
    var author: String?
    // swiftlint:disable:next identifier_name
    var _thumbNailUrlString: String?
    var description: String?
    let keywords: [String]? // can't store these as enums as the list can keep growing

    var id: URL { url } // computed property
    var thumbNailURL: URL? { URL(string: _thumbNailUrlString ?? "this will cause nil to be returned") }

    init(title: String, pubDate: Date, url: URL, keywords: [String]?) {
        self.title = title
        self.pubDate = pubDate
        self.url = url
        self.keywords = keywords
    }

}
