import Foundation
import SwiftUI

public struct HNUser: Codable {
    public let username: String
    public let joined: Date
    public let karma: Int
    public let bioHTML: String?
    public let submissionsIds: [Int]?

    private enum CodingKeys: String, CodingKey {
        case username = "id"
        case joined = "created"
        case karma
        case bioHTML = "about"
        case submissionsIds = "submitted"
    }
}

public extension HNUser {
    var hnURL: URL {
        HNURL.Website.user(id: username)
    }
}
