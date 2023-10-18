import Foundation
import SwiftUI

public struct HNItem: Codable, Identifiable, Hashable {

    // MARK: - Hacker News

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

    // MARK: - Algolia

    public let storyId: Int?
    public let comments: [HNItem]

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

    private enum AlgoliaCodingKeys: String, CodingKey {
        case author
        case comments = "children"
        case parentId
        case score = "points"
        case submitted = "created_at_i"
        case storyId
        case objectId
        case commentCount = "num_comments"
        case tags = "_tags"
    }
}

public extension HNItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        textHTML = try container.decodeIfPresent(String.self, forKey: .textHTML)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        titleHTML = try container.decodeIfPresent(String.self, forKey: .titleHTML)
        
        let algoliaContainer = try decoder.container(keyedBy: AlgoliaCodingKeys.self)
        let isFromAlgolia = try algoliaContainer.decodeIfPresent(Int.self, forKey: .objectId) != nil
        
        if isFromAlgolia {
            id = try algoliaContainer.decode(Int.self, forKey: .objectId)
            
            let tags = try algoliaContainer.decode([String].self, forKey: .tags)
            let typeTag = tags[0]
            let typeFromTag = HNItemType(rawValue: typeTag)!
            type = typeFromTag
            
            deleted = false
            author = try algoliaContainer.decode(String.self, forKey: .author)
            submitted = try algoliaContainer.decode(Date.self, forKey: .submitted)
            dead = false
            commentsIds = []
            score = try algoliaContainer.decodeIfPresent(Int.self, forKey: .score) ?? 0
            pollOptionsIds = []
            pollId = nil
            parentId = try algoliaContainer.decodeIfPresent(Int.self, forKey: .parentId)
            commentCount = try algoliaContainer.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0

            storyId = try algoliaContainer.decodeIfPresent(Int.self, forKey: .storyId)
            comments = try algoliaContainer.decodeIfPresent([HNItem].self, forKey: .comments) ?? []
        } else {
            id = try container.decode(Int.self, forKey: .id)
            type = try container.decode(HNItemType.self, forKey: .type)
            deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted) ?? false
            author = try container.decode(String.self, forKey: .author)
            submitted = try container.decode(Date.self, forKey: .submitted)
            dead = try container.decodeIfPresent(Bool.self, forKey: .dead) ?? false
            commentsIds = try container.decodeIfPresent([Int].self, forKey: .commentIds) ?? []
            score = try container.decodeIfPresent(Int.self, forKey: .score) ?? 0
            pollOptionsIds = try container.decodeIfPresent([Int].self, forKey: .pollOptionsIds) ?? []
            pollId = try container.decodeIfPresent(Int.self, forKey: .pollId)
            parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
            commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
            
            storyId = nil
            comments = []
        }
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
        commentCount > 0 || comments.count > 0
    }
}
