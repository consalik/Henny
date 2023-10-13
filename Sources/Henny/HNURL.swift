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

    enum HackerNews: String {
        case login
        case vote
        case fave

        var url: URL {
            return HNURL.website.appendingPathComponent(self.rawValue)
        }
    }
}
