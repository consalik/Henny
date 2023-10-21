import Foundation
import SwiftUI
import LinkPresentation

public struct HNItem: Codable, Identifiable, Hashable {
    
    // MARK: - API
    
    public let id: Int
    public let deleted: Bool
    public let type: HNItemType
    public let author: String
    public let submitted: Date
    public let textHTML: String?
    public let dead: Bool
    public let commentsIds: [Int]
    public let url: URL?
    public let score: Int
    public let titleHTML: String?
    public let pollOptionsIds: [Int]
    public let pollId: Int?
    public let parentId: Int?
    public let commentCount: Int

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
        case commentCount = "descendants"
    }

    public init(id: Int, deleted: Bool, type: HNItemType, author: String, submitted: Date, textHTML: String?, dead: Bool, commentsIds: [Int], url: URL?, score: Int, titleHTML: String?, pollOptionsIds: [Int], pollId: Int?, parentId: Int?, commentCount: Int) {
        self.id = id
        self.deleted = deleted
        self.type = type
        self.author = author
        self.submitted = submitted
        self.textHTML = textHTML
        self.dead = dead
        self.commentsIds = commentsIds
        self.url = url
        self.score = score
        self.titleHTML = titleHTML
        self.pollOptionsIds = pollOptionsIds
        self.pollId = pollId
        self.parentId = parentId
        self.commentCount = commentCount
    }
    
    // MARK: - Custom
    
    public var metadata: LPLinkMetadata?
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
        commentsIds = try container.decodeIfPresent([Int].self, forKey: .commentIds) ?? []
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        score = try container.decodeIfPresent(Int.self, forKey: .score) ?? 0
        titleHTML = try container.decodeIfPresent(String.self, forKey: .titleHTML)
        pollOptionsIds = try container.decodeIfPresent([Int].self, forKey: .pollOptionsIds) ?? []
        pollId = try container.decodeIfPresent(Int.self, forKey: .pollId)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
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
        try container.encode(commentsIds, forKey: .commentIds)
        try container.encode(url, forKey: .url)
        try container.encode(score, forKey: .score)
        try container.encode(titleHTML, forKey: .titleHTML)
        try container.encode(pollOptionsIds, forKey: .pollOptionsIds)
        try container.encode(pollId, forKey: .pollId)
        try container.encode(parentId, forKey: .parentId)
        try container.encode(commentCount, forKey: .commentCount)
    }
}

public extension HNItem {
    var hnURL: URL {
        HNURL.Website.item(id: id)
    }
    
    var document: Bool {
        return titleHTML?.contains("[pdf]") ?? false
    }
    
    var updated: Bool {
        return titleHTML?.contains("[updated]") ?? false
    }
    
    var video: Bool {
        return titleHTML?.contains("[video]") ?? false
    }
    
    var delayed: Bool {
        textHTML == "[delayed]"
    }

    var hasComments: Bool {
        commentCount > 0
    }
    
    var host: String? {
        url?.host?.replacingOccurrences(of: "www.", with: "", options: .regularExpression)
    }
}
