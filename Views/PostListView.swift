//
//  PostingsView.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import SwiftUI

struct PostListView: View {

    var testString: String?

    @State var blogPosts = [Post]()
    @State var searchText: String = ""
    @Environment(\.isSearching) private var isSearching
    @Environment(\.managedObjectContext) var context

    private let jsonDateFormatter = DateFormatter() // formatter for dates in JSON data
    private let viewDateFormatter = makeViewDateFormatter() // formatter for displaying dates

    let swiftLeeFeed2Url = "https://api.rss2json.com/v1/api.json?rss_url=https://www.avanderlee.com/feed?paged="
    private let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
                                                                .destructiveAction : // iPad: Search field in toolbar
                                                                .navigationBarTrailing // iPhone: Search field in drawer

    var body: some View {

        VStack {
            NavigationView {
                List {
                    Stats(searchResultsCount: searchResults.count, blogPostsCount: blogPosts.count)
                    ForEach(searchResults) { blogPost in
                        HStack(alignment: .top) {
                            Image(systemName: "envelope.fill") // see also "envelope.open.fill"
                                .padding(.top, 4.5)
                                .foregroundColor(.brown)
                            VStack(alignment: .leading) {
                                Link(destination: URL(string: blogPost.url) ??
                                                  URL(string: "http:www.example.com")!, label: {
                                    Text(blogPost.title)
                                        .font(.title3)
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                        .foregroundColor(.accentColor)
                                })
                                Text(blogPost.url/*.absoluteString*/)
                                    .lineLimit(1)
                                    .truncationMode(.head)
                                    .foregroundColor(.gray)
                                Text(viewDateFormatter.string(from: blogPost.publicationDate))
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: "Title search")
                .toolbar {
                    ToolbarItemGroup(placement: toolbarItemPlacement) {
                        Text("(\(searchResults.count) of \(blogPosts.count))")
                            .foregroundColor(.gray)
                            .font(.callout)
                    }
                }
                .refreshable { }
                .onAppear {
                    if testString == nil {
                        fillBlogPostsFromSite()
                    } else { // fetch online data
                        fillBlogPostsFromString(string: testString!)
                    }
                }
                .animation(.spring(), value: searchText) // non-default animations don't work?
                .navigationTitle("SwiftLee")
            }
            .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
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

    var searchResults: [Post] { // helper function to support .searchable() view modifier
        if searchText.isEmpty {
            return blogPosts // no filtering
        } else {
            return blogPosts.filter { $0.title.lowercased().contains(searchText.lowercased()) } // case insensitive
        }
    }

    func fetchJsonData(page: Int) async -> [Post] {
        guard page > 0 else { fatalError("page value must be positive (but is \(page)") } // a bit paranoid, I guess

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

    func fillBlogPostsFromSite() {
        Task {
            if blogPosts.isEmpty { // we expect blogPosts[] to be empty
                var page = 0
                var newPage: [Post] // list of posts on page
                var pageSize = 0 // we determine server's max page size dynamically (it's probably 10)

                repeat { // fetching one page at a time (note: we don't know home many to expect)
                    page += 1
                    newPage = await fetchJsonData(page: page)
                    blogPosts.append(contentsOf: newPage)
                    try context.save()
                    pageSize = max(pageSize, newPage.count) // largest received page
                } while newPage.count == pageSize // stop on first empty or partially filled page

                // reporting
                print("""
                      Found a total of \(blogPosts.count) posts \
                      on \(blogPosts.count/pageSize) pages \
                      with \(pageSize) posts each
                      """, terminator: "")
                if newPage.count==0 {
                    print(".") // no partially filled page at end
                } else { // partially filled page at end
                    let remainder = blogPosts.count % pageSize
                    print(", plus a final page containing the last \(remainder) posts.")
                }
            } else {
                print("Warning: we almost filled the blogPosts array a second time. Check why!")
            }
        }
    }

    func fillBlogPostsFromString(string: String) {
        do { // fetch offline data
            let jsonData = string.data(using: .utf8)!
            let root = try getDecoder().decode(Page.self, from: jsonData)
            blogPosts = root.postings
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostListView(testString: hardcodedJsonString)
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
