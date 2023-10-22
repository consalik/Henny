import Foundation
import AlgoliaSearchClient

public struct HNAlgoliaClient {
    
    private let searchClient: SearchClient
    
    init(appId: ApplicationID, apiKey: APIKey) {
        self.searchClient = SearchClient(appID: appId, apiKey: apiKey)
    }
    
    // MARK: - Coding
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .secondsSince1970
        
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return decoder
    }()
}
