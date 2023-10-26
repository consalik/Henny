import Foundation

public struct HNComment: Codable, Equatable {
    public let item: HNItem
    public let comments: [HNComment]
}

extension HNComment: Identifiable {
    public var id: Int {
        item.id
    }
}
