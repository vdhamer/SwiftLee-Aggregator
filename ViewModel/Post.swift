//
//  Posting.swift
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
                return Date()
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
                return "Error because stored shortURL is nil"
            }
        }
        set {
            shortURL_ = newValue
        }
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
        get {
            synopsis_ ?? "No summary of post available."
        }
        set {
            synopsis_ = newValue
        }
    }

    var id: String { // computed property
        title
    }

    var readIt: Bool { // computed property
        get {
            if let storedValue = readIt_ {
                return storedValue == 1
            } else {
                return false
            }
        }
        set {
            switch newValue {
            case true: readIt_ = 1
            case false: readIt_ = 0
            }
        }
    }

    var star: Bool { // computed property
        get {
            if let storedValue = star_ {
                return storedValue == 1
            } else {
                return false
            }
        }
        set {
            switch newValue {
            case true: star_ = 1
            case false: star_ = 0
            }
        }
    }

}

extension Post {

    static func persistReadIt(objectId: NSManagedObjectID,
                              context: NSManagedObjectContext,
                              newValue: Bool) {

        guard let post = fetchPost(for: objectId, context: context) else { fatalError("Cannot find Post") }

        post.readIt = newValue

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

        post.star = newValue

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

// extension Post { // findCreateUpdate() records in Post table
//
//    // Find existing object or create a new object
//    // Update existing attributes or fill the new object
//    static func findCreateUpdate(context: NSManagedObjectContext,
//                                 // identifying attributes
//                                 title: String,
//                                  // other attributes of a Post
//                                 publicationDate: Date, url: String, shortURL: String,
//                                 author: String, thumbNailURL: String, synopsis: String
//                                ) -> Post {
//
//        let predicateFormat: String = "title_ = %@" // avoid localization, search on identifying attr's only
//        let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, title))
//
//        let posts: [Post] = (try? context.fetch(request)) ?? [] // nil means absolute failure
//
//        if let post = posts.first { // already exists, so make sure secondary attributes are up to date
//            let updated: Bool = update(context: context, post: post,
//                                       publicationDate: publicationDate, url: url, shortURL: shortURL,
//                                       author: author, thumbNailURL: thumbNailURL, synopsis: synopsis)
//            if updated {
//                print("Updated info for post \(post.id) published on \(post.publicationDate)")
//            }
//            return post
//        } else {
//            let post = Post(context: context) // create new Member object
//            post.title_ = title
//            _ = update(context: context, post: post,
//                       publicationDate: publicationDate, url: url, shortURL: shortURL,
//                       author: author, thumbNailURL: thumbNailURL, synopsis: synopsis)
//            print("Created new record for post \(post.id) published on \(post.publicationDate)")
//            return post
//        }
//    }
//
//    // Update non-identifying attributes/properties within existing instance of class PhotoClub
//    private static func update(context: NSManagedObjectContext, post: Post,
//                               publicationDate: Date?, url: String?, shortURL: String?,
//                               author: String?, thumbNailURL: String?, synopsis: String?
//                              ) -> Bool {
//        var modified: Bool = false
//
//        // function only works for non-optional Types.
//        // If optional support needed, create variant with "inout Type?" instead of "inout Type"
//        func updateIfChanged<Type>(update persistedValue: inout Type, with newValue: Type?) where Type: Equatable {
//            if let newValue = newValue { // if newValue == nil, don't change persistedValue
//                if newValue != persistedValue {
//                    persistedValue = newValue
//                    modified = true
//                }
//            }
//        }
//
//        updateIfChanged(update: &post.publicationDate, with: publicationDate)
//        updateIfChanged(update: &post.url, with: url)
//        updateIfChanged(update: &post.shortURL, with: shortURL)
//
//        updateIfChanged(update: &post.author, with: author)
//        updateIfChanged(update: &post.thumbNailURL, with: thumbNailURL)
//        updateIfChanged(update: &post.synopsis, with: synopsis)
//
//        if modified {
//            do {
//                try context.save()
//            } catch {
//                fatalError("Update failed for for post \(post.id) published on \(post.publicationDate)" +
//                           "\(error)")
//            }
//        }
//        return modified
//    }
//
// }

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
