import Foundation

enum HNItemType: String, Codable, CaseIterable, Identifiable {
    case job
    case story
    case comment
    case poll
    case pollOption

    private enum CodingKeys: String, CodingKey {
        case job
        case story
        case comment
        case poll
        case pollOption = "pollopt"
    }
}

extension HNItemType {
    var id: String {
        self.rawValue
    }
    
    var name: String {
        switch self {
        case .job:
            return "Job"
        case .story:
            return "Story"
        case .comment:
            return "Comment"
        case .poll:
            return "Poll"
        case .pollOption:
            return "Poll Option"
        }
    }
}
