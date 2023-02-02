//
//  PostListInnerView.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 01/02/2023.
//

import SwiftUI
import CoreData

struct PostListInnerView: View {
    let post: Post
    let context: NSManagedObjectContext

    var viewDateFormatter: DateFormatter // formatter for displaying dates overwritten in init()

    init(post: Post, context: NSManagedObjectContext) {
        self.post = post
        self.context = context
        viewDateFormatter = DateFormatter() // to keep Swift happy
        self.viewDateFormatter = self.makeViewDateFormatter()
    }

    var body: some View {

        HStack(alignment: .top) {
            VStack {
                Image(systemName: "circle.fill")
                    .opacity(post.readIt ? 0 : 1) // hide and unhide
                    .padding(.top, 4.5)
                    .foregroundColor(.brown)
                Image(systemName: "star.fill")
                    .opacity(post.star ? 1 : 0) // hide and unhide
                    .padding(.top, 4.5)
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading) {
                Link(destination: URL(string: post.url) ??
                                  URL(string: "https://www.example.com")!, label: {
                    Text(post.title)
                        .font(.title3)
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .foregroundColor(.accentColor)
                })
                    .environment(\.openURL, OpenURLAction { _ in
                        post.readIt = true
                        Post.persistReadIt(objectId: post.objectID, context: context, newValue: true)
                        return .systemAction
                    })
                Text(post.url)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundColor(.gray)
                Text(viewDateFormatter.string(from: post.publicationDate))
                    .font(.footnote)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                post.star.toggle()
                Post.persistStar(objectId: post.objectID, context: context, newValue: post.star)
            } label: {
                Star(current: post.star)
            }
            Button {
                post.readIt.toggle()
                Post.persistReadIt(objectId: post.objectID, context: context, newValue: post.readIt)
            } label: {
                Label("Unread", systemImage: post.readIt ? "envelope.fill" : "envelope.open.fill")
                    .foregroundColor(.brown)
            }
        }
    }

    private struct Star: View {
        var current: Bool

        var body: some View {
            Image(systemName: current ? "star.slash" : "star.fill")
                .foregroundStyle(.yellow, .gray, .red)
                .symbolRenderingMode(.palette)
        }
    }

    private func makeViewDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd, yyyy"
        return formatter
    }
}
