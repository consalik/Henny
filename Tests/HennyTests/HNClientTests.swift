import XCTest
import FirebaseCore

@testable import Henny

final class HNClientTests: XCTestCase {
    
    override class func setUp() {
        FirebaseApp.configure(options: .init(googleAppID: "YOUR_GOOGLE_APP_ID", gcmSenderID: "YOUR_GCM_SENDER_ID"))
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
    
    // MARK: - Story IDs
    
    func testStoryIdsForAllStoryTypesShouldExist() async {
        for storyType in HNStoryType.allCases {
            let storyIds = await HNClient.shared.storyIds(type: storyType)
            
            XCTAssertNotNil(storyIds)
            XCTAssertGreaterThan(storyIds.count, 0)
        }
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
