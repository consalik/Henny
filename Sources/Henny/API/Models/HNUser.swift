import Foundation
import SwiftUI

public struct HNUser: Codable {
    public let username: String
    public let joined: Date
    public let karma: Int
    public let bioHTML: String?
    public let submissions: [Int]?

    private enum CodingKeys: String, CodingKey {
        case username = "id"
        case joined = "created"
        case karma
        case bioHTML = "about"
        case submissions = "submitted"
    }
}

public extension HNUser {
    var hnURL: URL {
        return URL(string: "\(HNURL.website)/user?id=\(username)")!
    }
    
    var bioMarkdown: LocalizedStringKey? {
        guard let bioHTML else {
            return nil
        }
        
        var bioMarkdown = bioHTML
        
        bioMarkdown = bioMarkdown
            .replacingOccurrences(of: "<i>", with: "*")
            .replacingOccurrences(of: "</i>", with: "*")

            .replacingOccurrences(of: "<b>", with: "**")
            .replacingOccurrences(of: "</b>", with: "**")

            .replacingOccurrences(of: "<p>", with: "\n\n")
        
        let cleanBioMarkdown = LocalizedStringKey(bioMarkdown)
        
        return cleanBioMarkdown
    }
}
