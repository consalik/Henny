import XCTest
import FirebaseCore

@testable import Henny

final class HNAuthClientTests: XCTestCase {
    
    override class func setUp() {
        FirebaseApp.configure(options: .init(googleAppID: "", gcmSenderID: ""))
    }
    
    override func setUpWithError() throws {
        if HNAuthClient.shared.signedIn() {
            try HNAuthClient.shared.signOut()
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

    func testShouldNotBeAbleToSignOutIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try HNAuthClient.shared.signOut()
            XCTFail("Should not be able to sign out if not signed in")
        } catch let error as HNAuthClient.SignOutError {
            XCTAssertEqual(error, HNAuthClient.SignOutError.notSignedIn)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldBeAbleToSignOutIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())

            try HNAuthClient.shared.signOut()
            XCTAssertFalse(HNAuthClient.shared.signedIn())
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - User

    func testShouldNotReturnUserIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            _ = try await HNAuthClient.shared.user()
            XCTFail("Should not return user if not signed in")
        } catch let error as HNAuthClient.UserError {
            XCTAssertEqual(error, HNAuthClient.UserError.notSignedIn)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldReturnUserIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())

            let user = try await HNAuthClient.shared.user()
            XCTAssertEqual(user.username, HennyTests.validUsername)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Voting

    func testShouldNotBeAbleToVoteIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.vote(id: 1, direction: .up)
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

            try await HNAuthClient.shared.vote(id: 1, direction: .up)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
