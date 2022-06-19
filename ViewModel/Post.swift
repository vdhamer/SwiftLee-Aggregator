//
//  Posting.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import CoreData

class Post: NSManagedObject, Decodable {
    // https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/

    enum CodingKeys: String, CodingKey, Hashable { // in same order as JSON file
        case title
        case publicationDate = "pubDate"
        case url = "link"
        case shortURL = "guid"
        case author
        case thumbNailURL = "thumbnail"
        case synopsis = "description"
        // missing content
        // missing enclosure
        // missing catagories
    }

    required convenience init(from decoder: Decoder) throws {

        self.init(context: PersistenceController.shared.container.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int64.self, forKey: .id) // TODO: needed?
        self.title = try container.decode(String.self, forKey: .title)
        self.publicationDate = try container.decode(Date.self, forKey: .publicationDate)
        self.url = try container.decode(String.self, forKey: .url)
        self.shortURL = try container.decode(String.self, forKey: .shortURL)
        self.author = try container.decode(String.self, forKey: .author)
        self.thumbNailURL = try container.decode(String.self, forKey: .thumbNailURL)
        self.synopsis = try container.decode(String.self, forKey: .synopsis)
        // missing content
        // missing enclosure
        // missing catagories
    }

    var author: String {
        get {
            if let author = author_ {
                return author
            } else {
                fatalError("Error because stored author is nil")
            }
        }
        set {
            author_ = newValue
        }
    }

    var publicationDate: Date {
        get {
            if let publicationDate = publicationDate_ {
                return publicationDate
            } else {
                fatalError("Error because stored publicationDate is nil")
            }
        }
        set {
            publicationDate_ = newValue
        }
    }

    var id: String { // computed property
        title
    }

    var shortURL: String {
        get {
            if let shortURL = shortURL_ {
                return shortURL
            } else {
                fatalError("Error because stored shortURL is nil")
            }
        }
        set {
            shortURL_ = newValue
        }
    }

    var synopsis: String {
        get {
            synopsis_ ?? "No summary of post available."
        }
        set {
            synopsis_ = newValue
        }
    }

    var thumbNailURL: String {
        get {
            if let thumbNailURL = thumbNailURL_ {
                return thumbNailURL
            } else {
                fatalError("Error because stored thumbNailURL is nil")
            }
        }
        set {
            thumbNailURL_ = newValue
        }
    }

    var title: String {
        get {
            if let title = title_ {
                return title
            } else {
                fatalError("Error because stored publicationDate is nil")
            }
        }
        set {
            title_ = newValue
        }
    }

    var url: String {
        get {
            if let url = url_ {
                return url
            } else {
                fatalError("Error because stored URL is nil") // TODO: String instead of URL
            }
        }
        set {
            url_ = newValue
        }
    }

}
