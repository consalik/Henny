import Foundation

public enum HNStoryType: String, Codable, CaseIterable {
    case top
    case new
    case best
    case ask
    case show
    case job
    
    private enum CodingKeys: String, CodingKey {
        case top
        case new
        case best
        case ask
        case show
        case job
    }
}

extension HNStoryType: Identifiable {
    public var id: String {
        self.rawValue
    }
}

public extension HNStoryType {
    var name: String {
        switch self {
        case .top:
            return "Top Stories"
        case .new:
            return "New Stories"
        case .best:
            return "Best Stories"
        case .ask:
            return "Ask HN"
        case .show:
            return "Show HN"
        case .job:
            return "Jobs"
        }
    }

    var databaseKey: String {
        "\(self.rawValue)stories"
    }
}
