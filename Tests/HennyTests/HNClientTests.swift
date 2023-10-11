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
    
    let validItemIds = [1, 1232, 272, 484, 457]
    let invalidItemIds = [-1231231231, 12312321123312, -12122112, 1912212312312, 912912381283218]
    
    // MARK: - Item
    
    func testItemWithValidIdShouldExist() async {
        let item = await HNClient.shared.item(id: validItemIds.randomElement()!)
        
        XCTAssertNotNil(item)
    }
    
    func testItemWithInvalidIdShouldNotExist() async {
        let item = await HNClient.shared.item(id: invalidItemIds.randomElement()!)
        
        XCTAssertNil(item)
    }
    
    func testItemShouldPersistWhenGoingOffline() async {
        let onlineItem = await HNClient.shared.item(id: validItemIds[0])
        XCTAssertNotNil(onlineItem)

        HNClient.shared.goOffline()
        
        let offlineItem = await HNClient.shared.item(id: validItemIds[0])
        XCTAssertNotNil(offlineItem)
    }
    
    // MARK: - Items
    
    func testItemsWithValidIdsShouldExist() async {
        let items = await HNClient.shared.items(ids: validItemIds)
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, validItemIds.count)
    }
    
    func testItemsWithInvalidIdsShouldNotExist() async {
        let items = await HNClient.shared.items(ids: invalidItemIds)
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, 0)
    }
    
    func testItemsWithMixedIdsShouldExist() async {
        let items = await HNClient.shared.items(ids: validItemIds + invalidItemIds)
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items.count, validItemIds.count)
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
    
    let validUsernames = ["dang", "Phoqe", "0xPersona", "pseudolus", "mikece"]
    let invalidUsernames = ["u912d9j812j9d21", "9k21d9kd", "102i09d1kd921k90d", "91912d8j9d12j891d2j89", "89jd12d81"]
    
    func testUserWithValidUsernameShouldExist() async {
        let user = await HNClient.shared.user(username: validUsernames.randomElement()!)
        
        XCTAssertNotNil(user)
    }
    
    func testUserWithInvalidUsernameShouldNotExist() async {
        let user = await HNClient.shared.user(username: invalidUsernames.randomElement()!)
        
        XCTAssertNil(user)
    }
    
    func testUserShouldPersistWhenGoingOffline() async {
        let onlineUser = await HNClient.shared.user(username: validUsernames[0])
        XCTAssertNotNil(onlineUser)

        HNClient.shared.goOffline()
        
        let offlineUser = await HNClient.shared.user(username: validUsernames[0])
        XCTAssertNotNil(offlineUser)
    }
}
