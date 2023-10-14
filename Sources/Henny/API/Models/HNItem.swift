import Foundation
import SwiftUI

public struct HNItem: Codable, Identifiable, Hashable {
    public let id: Int
    public let deleted: Bool
    public let type: HNItemType
    public let author: String
    public let submitted: Date
    public let textHTML: String?
    public let dead: Bool
    public let commentIds: [Int]
    public let url: URL?
    public let score: Int
    public let titleHTML: String?
    public let pollOptionsIds: [Int]
    public let pollId: Int?
    public let parentId: Int?
    public let commentCount: Int?

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
        commentIds = try container.decodeIfPresent([Int].self, forKey: .commentIds) ?? []
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        score = try container.decodeIfPresent(Int.self, forKey: .score) ?? 0
        titleHTML = try container.decodeIfPresent(String.self, forKey: .titleHTML)
        pollOptionsIds = try container.decodeIfPresent([Int].self, forKey: .pollOptionsIds) ?? []
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
    
    var document: Bool {
        return titleHTML?.contains("[pdf]") ?? false
    }
    
    var updated: Bool {
        return titleHTML?.contains("[updated]") ?? false
    }
    
    var video: Bool {
        return titleHTML?.contains("[video]") ?? false
    }
    
    var text: String? {
        guard let textHTML = textHTML else {
            return nil
        }

        let data = Data(textHTML.utf8)
        let attributedString = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )

        return attributedString?.string
    }
    
    var markdown: LocalizedStringKey? {
        guard let textHTML else {
            return nil
        }
        
        var markdown = textHTML
        
        markdown = markdown
            .replacingOccurrences(of: "<i>", with: "*")
            .replacingOccurrences(of: "</i>", with: "*")

            .replacingOccurrences(of: "<b>", with: "**")
            .replacingOccurrences(of: "</b>", with: "**")

            .replacingOccurrences(of: "<p>", with: "\n\n")
        
        let cleanMarkdown = LocalizedStringKey(markdown)
        
        return cleanMarkdown
    }
}
