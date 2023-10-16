import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseDatabaseSwift
import OSLog

public class HNClient {
    
    public static let shared = HNClient()
    
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

    public func item(id: Int) async -> HNItem? {
        let reference = databaseReference
            .child("item")
            .child("\(id)")
        
        guard let snapshot = try? await reference.getData(),
              let item = try? snapshot.data(as: HNItem.self, decoder: decoder) else {
            return nil
        }
        
        return item
    }
    
    // MARK: - Items
    
    public func items(ids: [Int], limit: Int? = nil, offset: Int = 0) async -> [HNItem] {
        if offset >= ids.count {
            return []
        }
        
        let endIndex = limit.map { min(offset + $0, ids.count) } ?? ids.count
        let idsToFetch = Array(ids[offset..<endIndex])

        if idsToFetch.isEmpty {
            return []
        }
        
        return await fetchItems(with: idsToFetch)
    }

    // MARK: - Items (Stream)

    public func items(ids: [Int], limit: Int? = nil, offset: Int = 0) -> AsyncStream<HNItem> {
        return createItemStream(with: ids, limit: limit, offset: offset)
    }
    
    // MARK: - Comments
    
    public func comments(forItem item: HNItem) async -> [HNComment] {
        let topLevelComments = await items(ids: item.commentIds)
        
        var nodes: [HNComment] = []
        for topLevelComment in topLevelComments {
            let comments = await comments(forItem: topLevelComment)
            
            nodes.append(HNComment(item: topLevelComment, comments: comments))
        }
        
        return nodes
    }

    // MARK: - Comments (Stream)

    public func comments(forItem item: HNItem) -> AsyncStream<HNComment> {
        AsyncStream(HNComment.self) { continuation in
            Task {
                let topLevelComments = await items(ids: item.commentIds)
                
                var nodes: [HNComment] = []
                for topLevelComment in topLevelComments {
                    let comments = await comments(forItem: topLevelComment)
                    
                    nodes.append(HNComment(item: topLevelComment, comments: comments))
                }
                
                for node in nodes {
                    continuation.yield(node)
                }
                
                continuation.finish()
            }
        }
    }

    // MARK: - Stories
    
    public func storyIds(type: HNStoryType) async -> [Int] {
        let reference = databaseReference
            .child("\(type.databaseKey)")
        
        guard let snapshot = try? await reference.getData(),
              let storyIds = try? snapshot.data(as: [Int].self, decoder: decoder) else {
            return []
        }
        
        return storyIds
    }

    public func storyItems(type: HNStoryType, limit: Int? = nil, offset: Int = 0) async -> [HNItem] {
        let storyIds = await storyIds(type: type)
        
        if offset >= storyIds.count {
            return []
        }

        let endIndex = limit.map { min(offset + $0, storyIds.count) } ?? storyIds.count
        let storyIdsToFetch = Array(storyIds[offset..<endIndex])

        return await items(ids: storyIdsToFetch)
    }

    // MARK: - Stories (Stream)
    
    public func storyItems(type: HNStoryType, limit: Int? = nil, offset: Int = 0) -> AsyncStream<HNItem> {
        AsyncStream(HNItem.self) { continuation in
            Task {
                let storyIds = await storyIds(type: type)
                
                guard offset < storyIds.count else {
                    continuation.finish()
                    return
                }

                let endIndex = limit.map { min(offset + $0, storyIds.count) } ?? storyIds.count
                let idsToFetch = Array(storyIds[offset..<endIndex])

                guard !idsToFetch.isEmpty else {
                    continuation.finish()
                    return
                }

                await withTaskGroup(of: HNItem?.self) { taskGroup in
                    for id in idsToFetch {
                        taskGroup.addTask(priority: .high) {
                            await self.item(id: id)
                        }
                    }

                    var emittedIds = Set<Int>()

                    for await itemOptional in taskGroup {
                        if let item = itemOptional, !emittedIds.contains(item.id) {
                            continuation.yield(item)
                            emittedIds.insert(item.id)
                        }
                    }

                    continuation.finish()
                }
            }
        }
    }
    
    // MARK: - User
    
    public func user(username: String) async -> HNUser? {
        let reference = databaseReference
            .child("user")
            .child(username)
        
        guard let snapshot = try? await reference.getData(),
              let user = try? snapshot.data(as: HNUser.self, decoder: decoder) else {
            return nil
        }
        
        return user
    }
    
    // MARK: - Helpers
    
    private func fetchItems(with ids: [Int]) async -> [HNItem] {
        var fetchedItems = [HNItem]()

        await withTaskGroup(of: HNItem?.self) { taskGroup in
            for id in ids {
                taskGroup.addTask {
                    await self.item(id: id)
                }
            }

            for await result in taskGroup {
                if let item = result {
                    fetchedItems.append(item)
                }
            }
        }

        return fetchedItems
    }
    
    private func createItemStream(with ids: [Int], limit: Int? = nil, offset: Int = 0) -> AsyncStream<HNItem> {
        AsyncStream(HNItem.self) { continuation in
            Task {
                let validIds = Array(ids[offset..<(limit.map { offset + $0 } ?? ids.count)])

                await withTaskGroup(of: HNItem?.self) { taskGroup in
                    for id in validIds {
                        taskGroup.addTask {
                            await self.item(id: id)
                        }
                    }

                    for await result in taskGroup {
                        if let item = result {
                            continuation.yield(item)
                        }
                    }
                }

                continuation.finish()
            }
        }
    }
}

