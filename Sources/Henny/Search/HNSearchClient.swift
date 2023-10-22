import Foundation
import AlgoliaSearchClient

public struct HNSearchClient {
    
    private let algoliaClient: SearchClient
    
    init(appId: ApplicationID, apiKey: APIKey) {
        self.algoliaClient = SearchClient(appID: appId, apiKey: apiKey)
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
    
    public func search(text: String, index: HNSearchIndex, hitsPerPage: Int) async throws -> [HNItem] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = query(text: text, hitsPerPage: hitsPerPage)
            let configuredIndex = configuredIndex(from: index)
            
            configuredIndex.search(query: query) { result in
                switch result {
                case .success(let response):
                    let objects = response.hits.map(\.object)
                    
                    do {
                        let objectsData = try encoder.encode(objects)
                        let searchItems = try decoder.decode([HNSearchItem].self, from: objectsData)
                        let items = searchItems.map(\.item)
                        
                        continuation.resume(returning: items)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func query(text: String, hitsPerPage: Int) -> Query {
        var query = Query(text)
        
        query.hitsPerPage = hitsPerPage
        
        return query
    }
    
    private func configuredIndex(from index: HNSearchIndex) -> Index {
        return algoliaClient.index(withName: index.name)
    }
}
