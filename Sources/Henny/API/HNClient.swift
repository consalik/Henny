import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseDatabaseSwift
import OSLog
import LinkPresentation
import SwiftUI

public class HNClient {
    
    public static let shared = HNClient()
    
    // MARK: - Cache
    
    private let itemCache = NSCache<NSNumber, HNItem>()
    private let userCache = NSCache<NSString, HNUser>()
    private let metadataCache = HNMetadataCache()
    
    // MARK: - Firebase
    
    private let database: Database
    private let databaseReference: DatabaseReference
    
    private let decoder: Database.Decoder = {
        let decoder = Database.Decoder()
        
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return decoder
    }()
    
    // MARK: - General
    
    private let notificationCenter = NotificationCenter.default
    
    // MARK: - Initialization
    
    init() {
        database = Database.database(url: HNURL.api(version: false).absoluteString)
        database.isPersistenceEnabled = true
        
        databaseReference = database.reference(fromURL: HNURL.api().absoluteString)
    }

    // MARK: - Item

    public func item(id: Int, metadata: Bool = false) async -> HNItem? {
        if let item = itemCache.object(forKey: NSNumber(value: id)) {
            return item
        }
        
        let reference = databaseReference
            .child("item")
            .child("\(id)")
        
        guard let snapshot = try? await reference.getData(),
              let item = try? snapshot.data(as: HNItem.self, decoder: decoder) else {
            return nil
        }
        
        if metadata, let url = item.url, let metadata = await self.metadata(for: url) {
            item.metadata = metadata
        }
        
        itemCache.setObject(item, forKey: NSNumber(value: id))
        
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
        
        let sortedItems = fetchedItems.sorted { lhs, rhs in
            guard let lhsIndex = ids.firstIndex(of: lhs.id),
                  let rhsIndex = ids.firstIndex(of: rhs.id) else {
                return false
            }
            return lhsIndex < rhsIndex
        }

        return sortedItems
    }

    public func items(ids: [Int], limit: Int? = nil, offset: Int = 0, metadata: Bool = false, ordered: Bool = false) -> AsyncStream<HNItem> {
        AsyncStream(HNItem.self) { continuation in
            Task {
                if offset >= ids.count {
                    continuation.finish()
                    return
                }
                
                let endIndex = limit.map { min(offset + $0, ids.count) } ?? ids.count
                let idsToFetch = Array(ids[offset..<endIndex])

                if idsToFetch.isEmpty {
                    continuation.finish()
                    return
                }

                if ordered {
                    await fetchAndYieldOrderedItems(ids: idsToFetch, metadata: metadata, continuation: continuation)
                } else {
                    await fetchAndYieldUnorderedItems(ids: idsToFetch, metadata: metadata, continuation: continuation)
                }

                continuation.finish()
            }
        }
    }
    
    // MARK: - Comments
    
    public func comments(forItem item: HNItem) async -> [HNComment] {
        let topLevelComments = await items(ids: item.commentsIds)
        
        var nodes: [HNComment] = []
        for topLevelComment in topLevelComments {
            let comments = await comments(forItem: topLevelComment)
            
            nodes.append(HNComment(item: topLevelComment, comments: comments))
        }
        
        return nodes
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
    
    public func storyItems(type: HNStoryType, limit: Int? = nil, offset: Int = 0, metadata: Bool = false, ordered: Bool = false) -> AsyncStream<HNItem> {
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

                if ordered {
                    await fetchAndYieldOrderedItems(ids: idsToFetch, metadata: metadata, continuation: continuation)
                } else {
                    await fetchAndYieldUnorderedItems(ids: idsToFetch, metadata: metadata, continuation: continuation)
                }

                continuation.finish()
            }
        }
    }

    
    // MARK: - User
    
    public func user(username: String) async -> HNUser? {
        if let user = userCache.object(forKey: NSString(string: username)) {
            return user
        }
        
        let reference = databaseReference
            .child("user")
            .child(username)
        
        guard let snapshot = try? await reference.getData(),
              let user = try? snapshot.data(as: HNUser.self, decoder: decoder) else {
            return nil
        }
        
        userCache.setObject(user, forKey: NSString(string: username))
        
        return user
    }
    
    // MARK: - Database
    
    internal func goOffline() {
        database.goOffline()
    }
    
    internal func goOnline() {
        database.goOnline()
    }
    
    // MARK: - Helpers
    
    private func metadata(for url: URL) async -> LPLinkMetadata? {
        if let metadata = try? metadataCache.metadata(for: url) {
            return metadata
        }
        
        let provider = LPMetadataProvider()
        
        provider.shouldFetchSubresources = false
        
        guard let metadata = try? await provider.startFetchingMetadata(for: url) else {
            return nil
        }
        
        try? metadataCache.set(metadata, for: url)
        
        return metadata
    }
    
    private func fetchAndYieldOrderedItems(ids: [Int], metadata: Bool, continuation: AsyncStream<HNItem>.Continuation) async {
        var fetchedItems: [Int: HNItem] = [:]

        await withTaskGroup(of: (Int, HNItem?).self) { taskGroup in
            for id in ids {
                taskGroup.addTask {
                    return (id, await self.item(id: id, metadata: metadata))
                }
            }

            for await (id, item) in taskGroup {
                if let item = item {
                    fetchedItems[id] = item
                }
            }
        }

        for id in ids {
            if let item = fetchedItems[id] {
                continuation.yield(item)
            }
        }
    }

    private func fetchAndYieldUnorderedItems(ids: [Int], metadata: Bool, continuation: AsyncStream<HNItem>.Continuation) async {
        await withTaskGroup(of: HNItem?.self) { taskGroup in
            for id in ids {
                taskGroup.addTask {
                    return await self.item(id: id, metadata: metadata)
                }
            }

            for await item in taskGroup {
                if let item = item {
                    continuation.yield(item)
                }
            }
        }
    }
}
