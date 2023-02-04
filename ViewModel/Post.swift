//
//  Post.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import CoreData
import Foundation

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
        // case readIt = "dummy1"
        // case star = "dummy2"
        // missing content
        // missing enclosure
        // missing catagories
    }

    required convenience init(from decoder: Decoder) throws {
        // this init() allows the Decoder to pump Posts directly into the database
        // we actually don't want to do this because we want to merge the decoded Posts with the database context

        self.init(context: PersistenceController.shared.container.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decode(String.self, forKey: .title)
        self.publicationDate = try container.decode(Date.self, forKey: .publicationDate)
        self.url = try container.decode(String.self, forKey: .url)
        self.shortURL = try container.decode(String.self, forKey: .shortURL)
        self.author = try container.decode(String.self, forKey: .author)
        self.thumbNailURL = try container.decode(String.self, forKey: .thumbNailURL)
        self.synopsis = try container.decode(String.self, forKey: .synopsis)
//        self.readIt = try container.decode(Bool.self, forKey: .readIt) // dummy
        // missing content
        // missing enclosure
        // missing categories
    }
}

extension Post {

    var title: String {
        get {
            if let title = title_ {
                return title
            } else {
                print("Error: stored title is nil")
                return "Error because stored title is nil"
            }
        }
        set {
            title_ = newValue
        }
    }

    var publicationDate: Date {
        get {
            if let publicationDate = publicationDate_ {
                return publicationDate
            } else {
                print("Error: stored publicationDate is nil")
                return Date() // today's date instead
            }
        }
        set {
            publicationDate_ = newValue
        }
    }

    var url: String {
        get {
            if let url = url_ {
                return url
            } else {
                print("Error: stored URL is nil")
                return "Error because stored URL is nil"
            }
        }
        set {
            url_ = newValue
        }
    }

    var shortURL: String {
        get {
            if let shortURL = shortURL_ {
                return shortURL
            } else {
                print("Error: stored shortURL is nil")
                // return unique string
                return "Error because stored shortURL is nil" + UUID().uuidString
            }
        }
        set {
            shortURL_ = newValue
        }
    }

    var id: String { // computed property
        return shortURL
    }

    var author: String {
        get {
            if let author = author_ {
                return author
            } else {
                print("Error: stored author is nil")
                return "Error because stored author is nil"
            }
        }
        set {
            author_ = newValue
        }
    }

    var thumbNailURL: String {
        get {
            if let thumbNailURL = thumbNailURL_ {
                return thumbNailURL
            } else {
                print("Error: stored thumbNailURL is  nil")
                return "Error because stored thumbNailURL is nil"
            }
        }
        set {
            thumbNailURL_ = newValue
        }
    }

    var synopsis: String {
        get { synopsis_ ?? "No summary of post available." }
        set { synopsis_ = newValue }
    }

    var wasRead: Bool { // computed property
        get { wasRead_ }
        set { wasRead_ = newValue }
    }

    var hasStar: Bool { // computed property
        get { hasStar_ }
        set { hasStar_ = newValue }
    }

}

extension Post {

    static func persistReadIt(objectId: NSManagedObjectID,
                              context: NSManagedObjectContext,
                              newValue: Bool) {

        guard let post = fetchPost(for: objectId, context: context) else { fatalError("Cannot find Post") }

        post.wasRead = newValue

        do {
            try context.save()
        } catch {
            print("Error setting read-status: \(error)")
        }
    }

    static func persistStar(objectId: NSManagedObjectID,
                            context: NSManagedObjectContext,
                            newValue: Bool) {

        guard let post = fetchPost(for: objectId, context: context) else { fatalError("Cannot find Post") }

        post.hasStar = newValue

        do {
            try context.save()
        } catch {
            print("Error setting star-status: \(error)")
        }
    }

    static private func fetchPost(for objectId: NSManagedObjectID, context: NSManagedObjectContext) -> Post? {
        guard let post = context.object(with: objectId) as? Post else { return nil }

        return post
    }
}

extension Post { // convenience function

    static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<Post> { // pre-iOS 15 version
        let request = NSFetchRequest<Post>(entityName: "Post")
        request.predicate = predicate // WHERE part of the SQL query
        request.sortDescriptors = [
                                    NSSortDescriptor(keyPath: \Post.publicationDate_, ascending: false)
        ]
        return request
    }

}
