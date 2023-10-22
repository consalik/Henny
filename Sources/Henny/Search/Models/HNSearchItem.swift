import Foundation

public struct HNSearchItem: Codable, Hashable {
    public let objectId: String
    public let parentId: Int?
    public let storyText: String?
    public let storyUrl: URL?
    public let storyId: Int?
    public let author: String
    public let submitted: Date
    public let relevancyScore: Int?
    public let title: String?
    public let url: URL?
    public let comments: [HNSearchItem]?
    public let commentText: String?
    public let commentCount: Int?
    public let children: [HNSearchItem]?
    public let points: Int?
    public let text: String?
    public let type: String?
    public let storyTitle: String?

    enum CodingKeys: String, CodingKey {
        case objectId = "objectID"
        case parentId
        case storyText
        case storyUrl
        case storyId
        case author
        case createdAt
        case submitted = "created_at_i"
        case relevancyScore
        case title
        case url
        case comments
        case commentText
        case commentCount = "num_comments"
        case children
        case points
        case text
        case type
        case storyTitle
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        objectId = try container.decode(String.self, forKey: .objectId)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        storyText = try container.decodeIfPresent(String.self, forKey: .storyText)
        storyUrl = try container.decodeIfPresent(URL.self, forKey: .storyUrl)
        storyId = try container.decodeIfPresent(Int.self, forKey: .storyId)
        author = try container.decode(String.self, forKey: .author)
        submitted = try container.decode(Date.self, forKey: .submitted)
        relevancyScore = try container.decodeIfPresent(Int.self, forKey: .relevancyScore)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        comments = try container.decodeIfPresent([HNSearchItem].self, forKey: .comments)
        commentText = try container.decodeIfPresent(String.self, forKey: .commentText)
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount)
        children = try container.decodeIfPresent([HNSearchItem].self, forKey: .children)
        points = try container.decodeIfPresent(Int.self, forKey: .points)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        storyTitle = try container.decodeIfPresent(String.self, forKey: .storyTitle)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(objectId, forKey: .objectId)
        try container.encodeIfPresent(parentId, forKey: .parentId)
        try container.encodeIfPresent(storyText, forKey: .storyText)
        try container.encodeIfPresent(storyUrl, forKey: .storyUrl)
        try container.encodeIfPresent(storyId, forKey: .storyId)
        try container.encode(author, forKey: .author)
        try container.encodeIfPresent(submitted, forKey: .submitted)
        try container.encodeIfPresent(relevancyScore, forKey: .relevancyScore)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(comments, forKey: .comments)
        try container.encodeIfPresent(commentText, forKey: .commentText)
        try container.encodeIfPresent(commentCount, forKey: .commentCount)
        try container.encodeIfPresent(children, forKey: .children)
        try container.encodeIfPresent(points, forKey: .points)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(storyTitle, forKey: .storyTitle)
    }
}

extension HNSearchItem: Identifiable {
    public var id: Int {
        Int(objectId)!
    }
}

public extension HNSearchItem {
    var item: HNItem {
        HNItem(
            id: id,
            deleted: false,
            type: .story, // TODO
            author: author,
            submitted: submitted,
            textHTML: text ?? storyText ?? commentText,
            dead: false,
            commentsIds: [],
            url: url ?? storyUrl,
            score: points ?? 0,
            titleHTML: title ?? storyTitle,
            pollOptionsIds: [],
            pollId: nil,
            parentId: parentId,
            commentCount: commentCount ?? 0
        )
    }
}
