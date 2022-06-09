//
//  PostingsView.swift
//  SwiftLeeAggregator
//
//  Created by Peter van den Hamer on 04/06/2022.
//

import SwiftUI

struct PostListView: View {

    @State var blogPosts: [Post]
    private let jsonDateFormatter = DateFormatter()
    private let viewDateFormatter = makeViewDateFormatter()
    var showSimulatedData = false
    let swiftLeeFeed2Url = "https://api.rss2json.com/v1/api.json?rss_url=https://www.avanderlee.com/feed?paged="

    var body: some View {

        VStack {
            NavigationView {
                List {
                    ForEach(blogPosts) { blogPost in
                        HStack(alignment: .top) {
                            Image(systemName: "envelope.fill") // see also "envelope.open.fill"
                                .padding(.top, 4.5)
                                .foregroundColor(.brown)
                            VStack(alignment: .leading) {
                                Link(destination: blogPost.url, label: {
                                    Text(blogPost.title)
                                        .font(.title3)
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                        .foregroundColor(.accentColor)
                                })
                                Text(blogPost.url.absoluteString)
                                    .lineLimit(1)
                                    .truncationMode(.head)
                                    .foregroundColor(.gray)
                                Text(viewDateFormatter.string(from: blogPost.pubDate))
                                    .font(.footnote)
                            }

                        }
                    }
                }
                .refreshable { }
                .onAppear {
                    if showSimulatedData {
                        do {
                            let jsonData = hardcodedJsonString.data(using: .utf8)!
                            let newBlogPosts = try getDecoder().decode([Post].self, from: jsonData)
                            blogPosts = newBlogPosts
                        } catch {
                            print("Error decoding hardcoded JSON string")
                            return
                        }
                    } else { // fetch online data
                        Task {
                            if blogPosts.isEmpty { // we expect blogPosts[] to be empty
                                var page = 0
                                var newPage: [Post] // list of posts on page
                                var pageSize = 0 // we determine server's max page size dynamically (it's probably 10)

                                repeat { // fetching one page at a time (note: we don't know home many to expect)
                                    page += 1
                                    newPage = await fetchJsonData(page: page)
                                    blogPosts.append(contentsOf: newPage)
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
                }
                .navigationTitle("SwiftLee (\(blogPosts.count) " +
                                 "\(blogPosts.count==1 ? "post" : "posts"))") // fancy plural
            }
            .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
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

    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        jsonDateFormatter.locale = Locale(identifier: "en_US")
        jsonDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(jsonDateFormatter)
        return decoder
    }

    let hardcodedJsonString: String = """
        [{
            "title": "Optionals in Swift explained: 5 things you should know",
            "link": "https://www.avanderlee.com/swift/optionals-in-swift-explained-5-things-you-should-know/",
            "pubDate": "2001-01-01T09:15:00Z"
        },
        {
            "title": "EXC_BAD_ACCESS crash error: Understanding and solving it",
            "link": "https://www.avanderlee.com/swift/exc-bad-access-crash/",
            "pubDate": "2002-02-02T09:15:00Z"
        },
        {
            "title": "Thread Sanitizer explained: Data Races in Swift",
            "link": "https://www.avanderlee.com/swift/thread-sanitizer-data-races/",
            "pubDate": "2003-03-03T09:15:00Z"
        }]
        """

}

private func makeViewDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM dd, yyyy"
    return formatter
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostListView(blogPosts: [Post(title: "MyTitle",
                                             pubDate: Date()-365*10,
                                             url: URL(string: "http://www.example.com")!,
                                             keywords: ["Swift", "SwiftUI"]
                                    )],
                    showSimulatedData: true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
    }
}
