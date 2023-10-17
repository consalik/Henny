import Foundation
import SwiftUI

public struct HNUser: Codable {
    public let username: String
    public let joined: Date
    public let karma: Int
    public let bioHTML: String?
    public let submissionsIds: [Int]

    private enum CodingKeys: String, CodingKey {
        case username = "id"
        case joined = "created"
        case karma
        case bioHTML = "about"
        case submissionsIds = "submitted"
    }
    
    init(username: String, joined: Date, karma: Int, bioHTML: String?, submissionsIds: [Int]) {
        self.username = username
        self.joined = joined
        self.karma = karma
        self.bioHTML = bioHTML
        self.submissionsIds = submissionsIds
    }
}

public extension HNUser {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        username = try container.decode(String.self, forKey: .username)
        joined = try container.decode(Date.self, forKey: .joined)
        karma = try container.decode(Int.self, forKey: .karma)
        bioHTML = try container.decodeIfPresent(String.self, forKey: .bioHTML)
        submissionsIds = try container.decodeIfPresent([Int].self, forKey: .submissionsIds) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(username, forKey: .username)
        try container.encode(joined, forKey: .joined)
        try container.encode(karma, forKey: .karma)
        try container.encodeIfPresent(bioHTML, forKey: .bioHTML)
        try container.encodeIfPresent(submissionsIds, forKey: .submissionsIds)
    }
}

public extension HNUser {
    var hnURL: URL {
        HNURL.Website.user(id: username)
    }
    
    var hasSubmissions: Bool {
        submissionsIds.count > 0
    }
}
