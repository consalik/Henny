import XCTest
import FirebaseCore

@testable import Henny

final class HNClientTests: XCTestCase {
    
    override class func setUp() {
        FirebaseApp.configure(options: .init(googleAppID: "", gcmSenderID: ""))
    }
    
    override func setUp() {
        HNClient.shared.goOnline()
    }
    
    // MARK: - Item
    
    func testItemWithValidIdShouldExist() async {
        let item = await HNClient.shared.item(id: HennyTests.validItemIds.randomElement()!)
        
        XCTAssertNotNil(item)
    }
    
    func testItemWithInvalidIdShouldNotExist() async {
        let item = await HNClient.shared.item(id: HennyTests.invalidItemIds.randomElement()!)
        
        XCTAssertNil(item)
    }
    
    func testItemShouldPersistWhenGoingOffline() async {
        let onlineItem = await HNClient.shared.item(id: HennyTests.validItemIds[0])
        XCTAssertNotNil(onlineItem)

        HNClient.shared.goOffline()
        
        let offlineItem = await HNClient.shared.item(id: HennyTests.validItemIds[0])
        XCTAssertNotNil(offlineItem)
    }
    
    // MARK: - Items
    
    func testItemsWithValidIdsShouldExist() async {
        let items = await HNClient.shared.items(ids: HennyTests.validItemIds)
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, HennyTests.validItemIds.count)
    }
    
    func testItemsWithInvalidIdsShouldNotExist() async {
        let items = await HNClient.shared.items(ids: HennyTests.invalidItemIds)
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, 0)
    }
    
    func testItemsWithMixedIdsShouldExist() async {
        let items = await HNClient.shared.items(ids: HennyTests.validItemIds + HennyTests.invalidItemIds)
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, HennyTests.validItemIds.count)
    }
    
    func testItemsWithNoIdsShouldNotExist() async {
        let items = await HNClient.shared.items(ids: [])
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, 0)
    }
    
//    func testItemsPaginationWithValidLimitAndOffset() async {
//        let allItems = await HNClient.shared.items(ids: HennyTests.validItemIds)
//        
//        let offset = 2
//        let limit = 2
//        let paginatedItems = await HNClient.shared.items(ids: HennyTests.validItemIds, limit: limit, offset: offset)
//        
//        XCTAssertEqual(paginatedItems, Array(allItems[offset..<(offset + limit)]))
//    }
    
    func testItemsPaginationWithOffsetBeyondList() async {
        let offset = 10
        let limit = 2
        let paginatedItems = await HNClient.shared.items(ids: HennyTests.validItemIds, limit: limit, offset: offset)
        
        XCTAssertEqual(paginatedItems.count, 0)
    }
    
    func testItemsPaginationWithZeroLimit() async {
        let offset = 1
        let limit = 0
        let paginatedItems = await HNClient.shared.items(ids: HennyTests.validItemIds, limit: limit, offset: offset)
        
        XCTAssertEqual(paginatedItems.count, 0)
    }
    
    // MARK: - Comments
    
    func testFetchCommentTreeForItemWithComments() async {
        let item = await HNClient.shared.item(id: HennyTests.validItemIds[0])
        XCTAssertNotNil(item)
        
        let commentTree = await HNClient.shared.comments(forItem: item!)
        XCTAssertGreaterThan(commentTree.count, 0)
    }

    func testRecursiveFetchForCommentsWithNestedComments() async {
        let commentItem = await HNClient.shared.item(id: HennyTests.validItemIds[1])
        XCTAssertNotNil(commentItem)
        
        let nestedCommentTree = await HNClient.shared.comments(forItem: commentItem!)
        XCTAssertTrue(containsCommentWithIds(nestedCommentTree, ids: commentItem!.commentIds))
    }

    private func containsCommentWithIds(_ nodes: [HNComment], ids: [Int]) -> Bool {
        for node in nodes {
            if ids.contains(node.item.id) || containsCommentWithIds(node.comments, ids: ids) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Stories
    
    func testStoryIdsForAllStoryTypesShouldExist() async {
        for storyType in HNStoryType.allCases {
            let storyIds = await HNClient.shared.storyIds(type: storyType)
            
            XCTAssertNotNil(storyIds)
            XCTAssertGreaterThan(storyIds.count, 0)
        }
    }
    
//    func testStoryItemsPaginationWithValidLimitAndOffset() async {
//        for storyType in HNStoryType.allCases {
//            let allItems = await HNClient.shared.storyItems(type: storyType)
//            
//            let offset = 2
//            let limit = 2
//            let paginatedItems = await HNClient.shared.storyItems(type: storyType, limit: limit, offset: offset)
//            
//            XCTAssertEqual(paginatedItems, Array(allItems[offset..<(offset + limit)]))
//        }
//    }

    func testStoryItemsPaginationWithOffsetBeyondList() async {
        for storyType in HNStoryType.allCases {
            let offset = 1000
            let limit = 2
            let paginatedItems = await HNClient.shared.storyItems(type: storyType, limit: limit, offset: offset)
            
            XCTAssertEqual(paginatedItems.count, 0)
        }
    }
    
    func testStoryItemsPaginationWithZeroLimit() async {
        for storyType in HNStoryType.allCases {
            let offset = 1
            let limit = 0
            let paginatedItems = await HNClient.shared.storyItems(type: storyType, limit: limit, offset: offset)
            
            XCTAssertEqual(paginatedItems.count, 0)
        }
    }
    
    // MARK: - Stories (Stream)
    
    func testShouldFetchStories() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!) {
            stories.append(story)
        }

        XCTAssertGreaterThan(stories.count, 0)
    }

    func testShouldFetchStoriesWithLimit() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!, limit: 10) {
            stories.append(story)
        }

        XCTAssertEqual(stories.count, 10)
    }

    func testShouldFetchStoriesWithLimitAndOffset() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!, limit: 10, offset: 10) {
            stories.append(story)
        }

        XCTAssertEqual(stories.count, 10)
    }

    func testShouldFetchStoriesWithLimitAndOffsetBeyondList() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!, limit: 10, offset: 1000) {
            stories.append(story)
        }

        XCTAssertEqual(stories.count, 0)
    }

    func testShouldFetchStoriesWithLimitAndZeroOffset() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!, limit: 10, offset: 0) {
            stories.append(story)
        }

        XCTAssertEqual(stories.count, 10)
    }

    func testShouldFetchStoriesWithZeroLimitAndOffset() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!, limit: 0, offset: 0) {
            stories.append(story)
        }

        XCTAssertEqual(stories.count, 0)
    }

    func testShouldFetchStoriesWithZeroLimitAndOffsetBeyondList() async {
        var stories: [HNItem] = []
        
        for await story in HNClient.shared.storyItems(type: HNStoryType.allCases.randomElement()!, limit: 0, offset: 1000) {
            stories.append(story)
        }

        XCTAssertEqual(stories.count, 0)
    }
    
    // MARK: - User
    
    func testUserWithValidUsernameShouldExist() async {
        let user = await HNClient.shared.user(username: HennyTests.validUsernames.randomElement()!)
        
        XCTAssertNotNil(user)
    }
    
    func testUserWithInvalidUsernameShouldNotExist() async {
        let user = await HNClient.shared.user(username: HennyTests.invalidUsernames.randomElement()!)
        
        XCTAssertNil(user)
    }
    
    func testUserShouldPersistWhenGoingOffline() async {
        let onlineUser = await HNClient.shared.user(username: HennyTests.validUsernames[0])
        XCTAssertNotNil(onlineUser)

        HNClient.shared.goOffline()
        
        let offlineUser = await HNClient.shared.user(username: HennyTests.validUsernames[0])
        XCTAssertNotNil(offlineUser)
    }
}
