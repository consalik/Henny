import Foundation
import AlgoliaSearchClient

public enum HNSearchIndex {
    case user
    case popularity
    case byDate
    case popularityOrdered
    
    var name: IndexName {
        switch self {
        case .user:
            "Item_production_ordered"
        case .popularity:
            "Item_production"
        case .byDate:
            "Item_production"
        case .popularityOrdered:
            "Item_production_ordered"
        }
    }
}
