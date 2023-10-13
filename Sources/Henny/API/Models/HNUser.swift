import Foundation

public struct HNUser: Codable {
    public let username: String
    public let joined: Date
    public let karma: Int
    public let bio: String?
    public let submissions: [Int]?

    private enum CodingKeys: String, CodingKey {
        case username = "id"
        case joined = "created"
        case karma
        case bio = "about"
        case submissions = "submitted"
    }
}

public extension HNUser {
    var hnURL: URL {
        return URL(string: "\(HNURL.website)/user?id=\(username)")!
    }
}
