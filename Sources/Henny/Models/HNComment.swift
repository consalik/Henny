import Foundation

public struct HNComment: Codable {
    let item: HNItem
    let comments: [HNComment]
}

extension HNComment: Identifiable {
    public var id: Int {
        item.id
    }
}
