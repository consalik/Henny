import Foundation

public struct HNItem: Codable, Identifiable, Hashable {
    public let id: Int
    let deleted: Bool
    let type: HNItemType
    let author: String
    let submitted: Date
    let textHTML: String?
    let dead: Bool
    let commentIds: [Int]?
    let url: URL?
    let score: Int
    let titleHTML: String?
    let pollOptionsIds: [Int]?
    let pollId: Int?
    let parentId: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case deleted
        case type
        case author = "by"
        case submitted = "time"
        case textHTML = "text"
        case dead
        case commentIds = "kids"
        case url
        case score
        case titleHTML = "title"
        case pollOptionsIds = "parts"
        case pollId = "poll"
        case parentId = "parent"
    }
}

public extension HNItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted) ?? false
        type = try container.decode(HNItemType.self, forKey: .type)
        author = try container.decode(String.self, forKey: .author)
        submitted = try container.decode(Date.self, forKey: .submitted)
        textHTML = try container.decodeIfPresent(String.self, forKey: .textHTML)
        dead = try container.decodeIfPresent(Bool.self, forKey: .dead) ?? false
        commentIds = try container.decodeIfPresent([Int].self, forKey: .commentIds)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        score = try container.decodeIfPresent(Int.self, forKey: .score) ?? 0
        titleHTML = try container.decodeIfPresent(String.self, forKey: .titleHTML)
        pollOptionsIds = try container.decodeIfPresent([Int].self, forKey: .pollOptionsIds)
        pollId = try container.decodeIfPresent(Int.self, forKey: .pollId)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(deleted, forKey: .deleted)
        try container.encode(type, forKey: .type)
        try container.encode(author, forKey: .author)
        try container.encode(submitted, forKey: .submitted)
        try container.encode(textHTML, forKey: .textHTML)
        try container.encode(dead, forKey: .dead)
        try container.encode(commentIds, forKey: .commentIds)
        try container.encode(url, forKey: .url)
        try container.encode(score, forKey: .score)
        try container.encode(titleHTML, forKey: .titleHTML)
        try container.encode(pollOptionsIds, forKey: .pollOptionsIds)
        try container.encode(pollId, forKey: .pollId)
        try container.encode(parentId, forKey: .parentId)
    }
}

public extension HNItem {
    var hnURL: URL {
        URL(string: "\(HNURL.website)/item?id=\(id)")!
    }
}
