import XCTest
import FirebaseCore

@testable import Henny

final class HNAuthClientTests: XCTestCase {
    
    override func setUpWithError() throws {
        if HNAuthClient.shared.signedIn() {
            HNAuthClient.shared.signOut()
        }
    }
    
    // MARK: - Sign In

    func testShouldNotBeAbleToSignInWithInvalidUsernameAndPassword() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.invalidUsername, password: HennyTests.invalidPassword)
            XCTFail("Should not be able to sign in with invalid username and password")
        } catch let error as HNAuthClient.SignInError {
            XCTAssertEqual(error, HNAuthClient.SignInError.invalidCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldBeAbleToSignInWithValidUsernameAndPassword() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Sign Out

    func testShouldBeAbleToSignOutIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())

            HNAuthClient.shared.signOut()
            XCTAssertFalse(HNAuthClient.shared.signedIn())
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - User Name

    func testShouldNotReturnUserNameIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())
        
        let username = HNAuthClient.shared.userName
        
        XCTAssertNil(username)
    }

    func testShouldReturnUserNameIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())
        
        try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
        XCTAssertTrue(HNAuthClient.shared.signedIn())
        
        let username = HNAuthClient.shared.userName
        
        XCTAssertNotNil(username)
    }
    
    // MARK: - User Cookie

    func testShouldNotReturnUserCookieIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())
        
        let cookie = HNAuthClient.shared.userCookie
        
        XCTAssertNil(cookie)
    }

    func testShouldReturnUserCookieIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())
        
        try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
        XCTAssertTrue(HNAuthClient.shared.signedIn())
        
        let cookie = HNAuthClient.shared.userCookie
        
        XCTAssertNotNil(cookie)
    }

    // MARK: - User Settings

    func testShouldNotReturnUserSettingsIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            let _ = try await HNAuthClient.shared.userSettings()
        } catch let error as HNAuthClient.UserSettingsError {
            XCTAssertEqual(error, HNAuthClient.UserSettingsError.notSignedIn)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldReturnUserSettingsIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())

            let _ = try await HNAuthClient.shared.userSettings()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Voting

    func testShouldNotBeAbleToVoteIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.vote(id: HennyTests.validItemIds.randomElement()!, direction: .up)
            XCTFail("Should not be able to vote if not signed in")
        } catch let error as HNAuthClient.VoteError {
            XCTAssertEqual(error, HNAuthClient.VoteError.notSignedIn)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldBeAbleToVoteIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())

            try await HNAuthClient.shared.vote(id: HennyTests.validItemIds.randomElement()!, direction: .up)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Submissions
    
//    func testSubmissionsShouldNotBeAbleToSubmitIfNotSignedIn() async throws {
//        XCTAssertFalse(HNAuthClient.shared.signedIn())
//
//        do {
//            try await HNAuthClient.shared.submit(title: "Test", url: nil, text: nil)
//            XCTFail("Should not be able to submit if not signed in")
//        } catch let error as HNAuthClient.SubmitError {
//            XCTAssertEqual(error, HNAuthClient.SubmitError.notSignedIn)
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
//    
//    func testSubmissionsShouldBeAbleToSubmitIfSignedIn() async throws {
//        XCTAssertFalse(HNAuthClient.shared.signedIn())
//
//        do {
//            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
//            XCTAssertTrue(HNAuthClient.shared.signedIn())
//
//            try await HNAuthClient.shared.submit(title: "Test", url: nil, text: "test")
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
}
