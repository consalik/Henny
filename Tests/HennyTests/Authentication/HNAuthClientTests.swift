import XCTest
import FirebaseCore

@testable import Henny

final class HNAuthClientTests: XCTestCase {
    
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

    func testShouldNotReturnUsernameIfNotSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())
        
        do {
            let _ = try HNAuthClient.shared.username()
        } catch let error as HNAuthClient.UsernameError {
            XCTAssertEqual(error, HNAuthClient.UsernameError.notSignedIn)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldReturnUsernameIfSignedIn() async throws {
        XCTAssertFalse(HNAuthClient.shared.signedIn())

        do {
            try await HNAuthClient.shared.signIn(username: HennyTests.validUsername, password: HennyTests.validPassword)
            XCTAssertTrue(HNAuthClient.shared.signedIn())

            let username = try HNAuthClient.shared.username()
            XCTAssertEqual(username, HennyTests.validUsername)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
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
