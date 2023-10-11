import Foundation

struct HNUser: Codable {
    let username: String
    let joined: Date
    let karma: Int
    let bio: String?
    let submissions: [Int]?

    private enum CodingKeys: String, CodingKey {
        case username = "id"
        case joined = "created"
        case karma
        case bio = "about"
        case submissions = "submitted"
    }
}

extension HNUser {
    var hnURL: URL {
        return URL(string: "\(HNURL.website)/user?id=\(username)")!
    }
}
