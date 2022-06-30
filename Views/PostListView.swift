//
//  PostingsView.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import SwiftUI

struct PostListView: View {

    var testString: String?

    @FetchRequest var postFetchRequest: FetchedResults<Post>
    @State var searchText: String = ""
    @Environment(\.isSearching) private var isSearching
    @Environment(\.managedObjectContext) var context

    private let jsonDateFormatter = DateFormatter() // formatter for dates in JSON data
    private let viewDateFormatter = makeViewDateFormatter() // formatter for displaying dates

    let swiftLeeFeed2Url = "https://api.rss2json.com/v1/api.json?rss_url=https://www.avanderlee.com/feed?paged="
    private let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
                                                                .destructiveAction : // iPad: Search field in toolbar
                                                                .navigationBarTrailing // iPhone: Search field in drawer

    init(testString: String?, predicate: NSPredicate) {
        self.testString = testString

        _postFetchRequest = FetchRequest<Post>(sortDescriptors: [ // replaces previous fetchRequest
                                                SortDescriptor(\.publicationDate_, order: .reverse)
                                            ],
                                             predicate: predicate,
                                             animation: .default)
    }

    var body: some View {

        VStack {
            NavigationView {
                List {
                    Stats(searchResultsCount: filteredPostQueryResults.count, blogPostsCount: postFetchRequest.count)
                    ForEach(filteredPostQueryResults) { post in
                        HStack(alignment: .top) {
                            VStack {
                                Image(systemName: post.readIt ? "envelope.open.fill" : "envelope.fill")
                                    .padding(.top, 4.5)
                                    .foregroundColor(.brown)
                                Image(systemName: "star.fill")
                                    .opacity(post.star ? 1 : 0)
                                    .padding(.top, 4.5)
                                    .foregroundColor(.yellow)
                            }
                            VStack(alignment: .leading) {
                                Link(destination: URL(string: post.url) ??
                                                  URL(string: "http:www.example.com")!, label: {
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
//                            .tint(.teal)
                            Button {
                                post.readIt.toggle()
                                Post.persistReadIt(objectId: post.objectID, context: context, newValue: post.readIt)
                            } label: {
                                Label("Unread", systemImage: post.readIt ? "envelope.fill" : "envelope.open.fill")
                                    .foregroundColor(.brown)
                            }
//                            .tint(.teal)
                        }
                    }
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: "Title search")
                .toolbar {
                    ToolbarItemGroup(placement: toolbarItemPlacement) {
                        Text("(\(filteredPostQueryResults.count) of \(postFetchRequest.count))")
                            .foregroundColor(.gray)
                            .font(.callout)
                    }
                }
                .onAppear {
                    fillBlogPosts()
                }
                .refreshable {
                    fillBlogPosts()
                }
                .animation(.spring(), value: searchText) // non-default animations don't work?
                .navigationTitle("SwiftLee")
            }
            .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
        }
    }

    struct Star: View {
        var current: Bool

        var body: some View {
            Image(systemName: current ? "star.slash" : "star.fill")
                .foregroundStyle(.yellow, .gray, .red)
                .symbolRenderingMode(.palette)
        }
    }

    struct Stats: View {
        @Environment(\.isSearching) private var isSearching
        let searchResultsCount: Int
        let blogPostsCount: Int

        // https://www.reddit.com/r/SwiftUI/comments/trtw8r/searchable_environment_var_dismisssearch_and/
        var body: some View {
                if UIDevice.isIPhone && isSearching {
                    HStack {
                        Spacer()
                        Text("Showing \(searchResultsCount) of \(blogPostsCount) " +
                             "\(searchResultsCount==1 ? "post" : "posts")")
                            .font(.callout)
                            .foregroundColor(.teal)
                        Spacer()
                    }
                    .foregroundColor(.gray)
                } else {
                    EmptyView()
                }
        }
    }

    var filteredPostQueryResults: [Post] { // helper function to support .searchable() view modifier
        if searchText.isEmpty {
            return postFetchRequest.filter { _ in // no filtering
                true
            }
        } else {
            return postFetchRequest.filter {
                $0.title.lowercased().contains(searchText.lowercased()) // case insensitive
            }
        }
    }

    func fetchJsonData(page: Int) async -> [Post] {
        guard page > 0 else { fatalError("page value must be positive (but is \(page)") } // maybe a bit paranoid

        let url = URL(string: swiftLeeFeed2Url+"\(page)&api_key=\(apiKey)")!
        let decoder = getDecoder()
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let root = try decoder.decode(Page.self, from: data)

            return root.postings
        } catch {
            print("Decoding of page failed.") // can happen if page number is too high
            return [Post]()
        }
    }

    func fillBlogPosts() {
        if testString == nil || testString == "" {
            fillBlogPostsFromServer()
        } else { // fetch online data
            fillBlogPostsFromString(string: testString!)
        }
    }

    func fillBlogPostsFromServer() {
        Task {
            print("fillBlogPostsFromServer()")
            var page = 0
            var newPage: [Post] // list of posts on page
            var pageSize = 0 // we determine server's max page size dynamically (it's probably 10)

            repeat { // fetching one page at a time (note: we don't know home many to expect)
                page += 1
                newPage = await fetchJsonData(page: page)
                try context.save()
                pageSize = max(pageSize, newPage.count) // largest received page
            } while newPage.count == pageSize // stop on first empty or partially filled page
        }
    }

    func fillBlogPostsFromString(string: String) {
        do { // fetch offline data
            let jsonData = string.data(using: .utf8)!
            _ = try getDecoder().decode(Page.self, from: jsonData)
            try context.save()
        } catch {
            print("Error decoding hardcoded JSON string: \"\(error)\"")
            return
        }
    }

    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        jsonDateFormatter.locale = Locale(identifier: "en_US")
        jsonDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(jsonDateFormatter)
        return decoder
    }

}

private func makeViewDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM dd, yyyy"
    return formatter
}

struct PostListView_Previews: PreviewProvider {
    @State static var searchText = ""
    static var previews: some View {
        PostListView(testString: hardcodedJsonString,
                     predicate: NSPredicate.all)
    }

    static let hardcodedJsonString: String = """
        {
          "status": "ok",
          "feed": {
            "url": "https://www.avanderlee.com/feed",
            "title": "SwiftLee",
            "link": "https://www.avanderlee.com/",
            "author": "",
            "description": "A weekly blog about Swift, iOS and Xcode Tips and Tricks",
            "image": ""
          },
          "items": [
            {
              "title": "The start of a new blog",
              "pubDate": "2015-05-02 12:52:51",
              "link": "https://www.avanderlee.com/swift/the-start-of-a-new-blog/",
              "guid": "http://www.avanderlee.com/?p=9",
              "author": "Antoine van der Lee",
              "thumbnail": "",
              "description": "\(description)",
              "content": "\(content)",
              "enclosure": {},
              "categories": [
                "Swift"
              ]
            }
          ]
        }
        """

    static let description: String = """
      <p>Hi there! After thinking a lot of starting my own blog, \
      I\u{2019}ve finally made the decision to create one!\\n\
      As iOS developer for my job I found myself experiencing a lot of problems, \
      writing solutions and figuring out what\u{2019}s the best way to create this UI. \
      Many times these are things to share with others, but until today I didn't had a place for that.\\n\
      Expect posts about iOS related topics, posts about my WWDC visit coming June \
      and libraries I\u{2019}ve settled up for iOS.
    """

    static let content: String = """
      <p>Hi there! After thinking a lot of starting my own blog, \
      I\u{2019}ve finally made the decision to create one!\\n\
      As iOS developer for my job I found myself experiencing a lot of problems, \
      writing solutions and figuring out what\u{2019}s the best way to create this UI. \
      Many times these are things to share with others, but until today I didn't had a place for that.\\n\
      Expect posts about iOS related topics, posts about my WWDC visit coming June \
      and libraries I\u{2019}ve settled up for iOS.
    """
}
