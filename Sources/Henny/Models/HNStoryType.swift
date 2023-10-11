import Foundation

enum HNStoryType: String, Codable, CaseIterable, Identifiable {
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

extension HNStoryType {
    var id: String {
        self.rawValue
    }

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
