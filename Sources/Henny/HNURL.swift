import Foundation

public struct HNURL {
    static let website = URL(string: "https://news.ycombinator.com")!

    private static let apiVersion = "v0"
    private static let algoliaVersion = "v1"

    static func api(version: Bool = true) -> URL {
        var url = URL(string: "https://hacker-news.firebaseio.com")!

        if version {
            url.appendPathComponent(apiVersion)
        }

        return url
    }

    static func algolia(version: Bool = true) -> URL {
        var url = URL(string: "https://hn.algolia.com/api")!

        if version {
            url.appendPathComponent(algoliaVersion)
        }

        return url
    }

    struct Website {
        static func item(id: Int) -> URL {
            return HackerNews
                .item
                .url
                .appending(
                    queryItems: [
                        URLQueryItem(name: "id", value: "\(id)")
                    ]
                )
        }

        static func user(id: String) -> URL {
            return HackerNews
                .user
                .url
                .appending(
                    queryItems: [
                        URLQueryItem(name: "id", value: id)
                    ]
                )
        }
        
        static func vote(id: Int, how: String, auth: String) -> URL {
            return HackerNews
                .vote
                .url
                .appending(
                    queryItems: [
                        URLQueryItem(name: "id", value: "\(id)"),
                        URLQueryItem(name: "how", value: how),
                        URLQueryItem(name: "auth", value: auth),
                    ]
                )
        }
    }
}

public extension HNURL {
    enum HackerNews: String {
        case login
        case vote
        case fave
        case item
        case user
        case xuser

        var url: URL {
            return HNURL.website.appendingPathComponent(self.rawValue)
        }
    }
}
