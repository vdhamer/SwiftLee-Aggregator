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
        // missing content
        // missing enclosure
        // missing catagories
    }

    required convenience init(from decoder: Decoder) throws {

        self.init(context: PersistenceController.shared.container.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)

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

    var url: String {
        get {
            if let url = url_ {
                return url
            } else {
                fatalError("Error because stored URL is nil")
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
                fatalError("Error because stored shortURL is nil")
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
                fatalError("Error because stored author is nil")
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
                fatalError("Error because stored thumbNailURL is nil")
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

}

extension Post { // findCreateUpdate() records in Post table

    // Find existing object or create a new object
    // Update existing attributes or fill the new object
    // swiftlint:disable:next function_parameter_count
    static func findCreateUpdate(context: NSManagedObjectContext,
                                 // identifying attributes TODO may not be the best identifier
                                 title: String,
                                  // other attributes of a Post
                                 publicationDate: Date, url: String, shortURL: String,
                                 author: String, thumbNailURL: String, synopsis: String
                                ) -> Post {

        let predicateFormat: String = "title_ = %@" // avoid localization, search on identifying attr's only
        let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, title))

        let posts: [Post] = (try? context.fetch(request)) ?? [] // nil means absolute failure TODO add error msg

        if let post = posts.first { // already exists, so make sure secondary attributes are up to date
            let updated: Bool = update(context: context, post: post,
                                       publicationDate: publicationDate, url: url, shortURL: shortURL,
                                       author: author, thumbNailURL: thumbNailURL, synopsis: synopsis)
            if updated {
                print("Updated info for post \(post.id) published on \(post.publicationDate)")
            }
            return post
        } else {
            let post = Post(context: context) // create new Member object
            post.title_ = title
            _ = update(context: context, post: post,
                       publicationDate: publicationDate, url: url, shortURL: shortURL,
                       author: author, thumbNailURL: thumbNailURL, synopsis: synopsis)
            print("Created new record for post \(post.id) published on \(post.publicationDate)")
            return post
        }
    }

    // Update non-identifying attributes/properties within existing instance of class PhotoClub
    // swiftlint:disable:next function_parameter_count
    private static func update(context: NSManagedObjectContext, post: Post,
                               publicationDate: Date?, url: String?, shortURL: String?,
                               author: String?, thumbNailURL: String?, synopsis: String?
                              ) -> Bool {
        var modified: Bool = false

        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // not sure about this, prevents error

        // function only works for non-optional Types.
        // If optional support needed, create variant with "inout Type?" instead of "inout Type"
        func updateIfChanged<Type>(update persistedValue: inout Type, with newValue: Type?) where Type: Equatable {
            if let newValue = newValue { // if newValue == nil, don't change persistedValue
                if newValue != persistedValue {
                    persistedValue = newValue
                    modified = true
                }
            }
        }

        updateIfChanged(update: &post.publicationDate, with: publicationDate)
        updateIfChanged(update: &post.url, with: url)
        updateIfChanged(update: &post.shortURL, with: shortURL)

        updateIfChanged(update: &post.author, with: author)
        updateIfChanged(update: &post.thumbNailURL, with: thumbNailURL)
        updateIfChanged(update: &post.synopsis, with: synopsis)

        if modified {
            do {
                try context.save()
            } catch {
                fatalError("Update failed for for post \(post.id) published on \(post.publicationDate)" +
                           "\(error)")
            }
        }
        return modified
    }

}

extension Post { // convenience function

    static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<Post> { // pre-iOS 15 version
        let request = NSFetchRequest<Post>(entityName: "Post")
        request.predicate = predicate // WHERE part of the SQL query
        request.sortDescriptors = [
                                    NSSortDescriptor(keyPath: \Post.title_, ascending: true)
        ]
        return request
    }

}
