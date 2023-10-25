import Foundation
import SwiftUI

public class HNUser: Codable {
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
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        username = try container.decode(String.self, forKey: .username)
        joined = try container.decode(Date.self, forKey: .joined)
        karma = try container.decode(Int.self, forKey: .karma)
        bioHTML = try container.decodeIfPresent(String.self, forKey: .bioHTML)
        submissionsIds = try container.decodeIfPresent([Int].self, forKey: .submissionsIds) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(username, forKey: .username)
        try container.encode(joined, forKey: .joined)
        try container.encode(karma, forKey: .karma)
        try container.encodeIfPresent(bioHTML, forKey: .bioHTML)
        try container.encodeIfPresent(submissionsIds, forKey: .submissionsIds)
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
    var hnURL: URL {
        HNURL.Website.user(id: username)
    }
    
    var hasSubmissions: Bool {
        submissionsIds.count > 0
    }
    
    var emails: [String]? {
        guard let bioHTML else {
            return nil
        }

        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        guard let matches = detector?.matches(in: bioHTML, options: [], range: NSRange(location: 0, length: bioHTML.utf16.count)) else {
            return nil
        }
        
        var emails: [String] = []

        for match in matches {
            guard let range = Range(match.range, in: bioHTML),
                  let url = URL(string: String(bioHTML[range])),
                  url.absoluteString.contains("@") else {
                continue
            }
            
            emails.append(url.absoluteString)
        }

        return emails
    }
}
