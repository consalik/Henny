import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseDatabaseSwift
import OSLog

public class HNClient {
    
    static let shared = HNClient()
    
    private let database: Database
    private let databaseReference: DatabaseReference
    
    init() {
        database = Database.database(url: HNURL.api(version: false).absoluteString)
        database.isPersistenceEnabled = true
        
        databaseReference = database.reference(fromURL: HNURL.api().absoluteString)
    }
    
    private let decoder: Database.Decoder = {
        let decoder = Database.Decoder()
        
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return decoder
    }()
    
    // MARK: - Database
    
    internal func goOffline() {
        database.goOffline()
    }
    
    internal func goOnline() {
        database.goOnline()
    }

    // MARK: - Item

    func item(id: Int) async -> HNItem? {
        let reference = databaseReference
            .child("item")
            .child("\(id)")
        
        guard let snapshot = try? await reference.getData(),
              let item = try? snapshot.data(as: HNItem.self, decoder: decoder) else {
            return nil
        }
        
        return item
    }

    func items(ids: [Int]) async -> [HNItem] {
        if ids.isEmpty {
            return []
        }
        
        let items: [HNItem]? = await withTaskGroup(of: HNItem?.self) { taskGroup in
            for id in ids {
                taskGroup.addTask(priority: .high) {
                    await self.item(id: id)
                }
            }
            
            var itemsSet = Set<HNItem>()
            itemsSet.reserveCapacity(ids.count)
            
            for await item in taskGroup {
                guard let item = item else {
                    continue
                }
                
                itemsSet.insert(item)
            }
            
            // this needs to happen here as we only have access to `ids` in the client.
            let sortedItems = itemsSet.sorted { lhs, rhs in
                guard let lhsIndex = ids.firstIndex(of: lhs.id),
                      let rhsIndex = ids.firstIndex(of: rhs.id) else {
                    return false
                }

                return lhsIndex < rhsIndex
            }
            
            return sortedItems
        }
        
        return items ?? []
    }
    
    // MARK: - Items

    func items(ids: [Int], limit: Int) async -> [HNItem] {
        let idsToFetch = Array(ids.prefix(min(limit, ids.count)))
        
        return await items(ids: idsToFetch)
    }

    func items(ids: [Int], limit: Int, offset: Int) async -> [HNItem] {
        if offset >= ids.count {
            return []
        }

        let endIndex = min(offset + limit, ids.count)
        let idsToFetch = Array(ids[offset..<endIndex])

        return await items(ids: idsToFetch)
    }

    // MARK: - Stories
    
    func storyIds(type: HNStoryType) async -> [Int] {
        let reference = databaseReference
            .child("\(type.databaseKey)")
        
        guard let snapshot = try? await reference.getData(),
              let storyIds = try? snapshot.data(as: [Int].self, decoder: decoder) else {
            return []
        }
        
        return storyIds
    }

    func storyItems(type: HNStoryType, limit: Int = Int.max, offset: Int = 0) async -> [HNItem] {
        let storyIds = await storyIds(type: type)
        
        if offset >= storyIds.count {
            return []
        }

        let endIndex = min(offset + limit, storyIds.count)
        let storyIdsToFetch = Array(storyIds[offset..<endIndex])

        return await items(ids: storyIdsToFetch)
    }
    
    // MARK: - Users
    
    func user(username: String) async -> HNUser? {
        let reference = databaseReference
            .child("user")
            .child(username)
        
        guard let snapshot = try? await reference.getData(),
              let user = try? snapshot.data(as: HNUser.self, decoder: decoder) else {
            return nil
        }
        
        return user
    }
}

