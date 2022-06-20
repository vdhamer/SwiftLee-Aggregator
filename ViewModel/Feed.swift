//
//  WrappedPosting.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 19/06/2022.
//

import CoreData

class Feed: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey, Hashable { // in same order as JSON file
//        case url // TODO:
        case title
        case urlBase = "link"
//        case author
//        case summary = "description"
//        case imageURL = "image"
    }

//    var url: String = ""
    var title: String = ""
    var urlBase: String = ""
//    var author: String = ""
//    var summary: String = ""
//    var imageURL: String = "" // var imageURL: URL? { URL(string: imageUrlString) }
    public var id: String { title }

    required convenience init(from decoder: Decoder) throws {

        self.init(context: PersistenceController.shared.container.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int64.self, forKey: .id)
//        self.url = try container.decode(String.self, forKey: .url)
        self.title = try container.decode(String.self, forKey: .title)
        self.urlBase = try container.decode(String.self, forKey: .urlBase)
//        self.author = try container.decode(String.self, forKey: .author)
//        self.summary = try container.decode(String.self, forKey: .summary)
//        self.urlBase = try container.decode(String.self, forKey: .urlBase)
//        self.imageURL = try container.decode(String.self, forKey: .imageURL)
    }
}
