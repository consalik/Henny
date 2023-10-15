import Foundation

public extension HNAuthClient {
    enum SignInError: Error {
        case alreadySignedIn
        case invalidCredentials
        case captchaVerificationNeeded
        case invalidResponse
    }
    
    enum SignOutError: Error {
        case notSignedIn
    }
    
    enum VoteError: Error {
        case notSignedIn
        case couldNotConvertItemPage
        case couldNotExtractAuthToken
        case couldNotVote
        case couldNotVerifyVote
        case voteDiffers
        case couldNotCheckAnchor
    }
    
    enum UserError: Error {
        case notSignedIn
        case noUsername
        case noUser
    }
    
    enum UsernameError: Error {
        case notSignedIn
        case invalidCookie
    }
    
    enum UserSettingsError: Error {
        case notSignedIn
        case couldNotConvertUserPage
        case invalidUserSettings
    }
    
    enum UpdateUserSettingsError: Error {
        case notSignedIn
        case couldNotConvertUserPage
        case invalidHmac
    }
}
