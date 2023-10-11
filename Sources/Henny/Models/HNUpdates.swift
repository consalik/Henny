import Foundation

public struct HNUpdates: Codable {
    let items: [Int]
    let profiles: [String]

    private enum CodingKeys: String, CodingKey {
        case items
        case profiles
    }
}
