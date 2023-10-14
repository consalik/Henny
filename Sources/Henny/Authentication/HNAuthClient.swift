import Foundation
import SwiftSoup

public struct HNAuthClient {
    public static let shared = HNAuthClient()
    
    // MARK: - Lifecycle
    
    public func signIn(username: String, password: String) async throws {
        guard !signedIn() else {
            throw SignInError.alreadySignedIn
        }
        
        let request = signInRequest(username: username, password: password)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw SignInError.invalidResponse
        }
        
        try checkCaptchaVerificationNeeded(html: html)
        
        guard signedIn() else {
            throw SignInError.invalidCredentials
        }
    }
    
    public func signedIn() -> Bool {
        let cookies = HTTPCookieStorage.shared.cookies(for: HNURL.HackerNews.login.url)

        guard let cookies = cookies,
            let cookie = cookies.first(where: { $0.name == "user" }),
            let _ = cookie.value.split(separator: "&").first,
            let _ = cookie.value.split(separator: "&").last else {
            return false
        }

        return true
    }
    
    public func signOut() throws {
        guard signedIn() else {
            throw SignOutError.notSignedIn
        }
        
        HTTPCookieStorage.shared.cookies(for: HNURL.HackerNews.login.url)?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
    }
    
    // MARK: - User
    
    public func username() -> String? {
        let cookies = HTTPCookieStorage.shared.cookies(for: HNURL.HackerNews.login.url)

        guard let cookies = cookies,
            let cookie = cookies.first(where: { $0.name == "user" }),
            let username = cookie.value.split(separator: "&").first else {
            return nil
        }

        return String(username)
    }
    
    public func settings() -> HNUserSettings? {
        return nil
    }
    
    // MARK: - Voting
    
    public func vote(id: Int, direction: HNVoteDirection) async throws {
        guard signedIn() else {
            throw VoteError.notSignedIn
        }
        
        guard let html = try await htmlForItem(id: id) else {
            throw VoteError.couldNotConvertItemPage
        }
        
        let anchorId = anchorId(id: id, direction: direction)
        
        guard let authToken = try authToken(anchorId: anchorId, html: html) else {
            throw VoteError.couldNotExtractAuthToken
        }
        
        do {
            try await vote(id: id, direction: direction, authToken: authToken)
        } catch {
            throw VoteError.couldNotVote
        }
        
        var voted = false
        
        do {
            voted = try await self.voted(id: id, direction: direction)
        } catch {
            throw VoteError.couldNotVerifyVote
        }
        
        guard voted else {
            throw VoteError.voteDiffers
        }
    }
    
    // MARK: - Helpers
    
    private func signInRequest(username: String, password: String) -> URLRequest {
        var request = URLRequest(url: HNURL.HackerNews.login.url)
        let body = "acct=\(username)&pw=\(password)"

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        return request
    }
    
    private func anchorId(id: Int, direction: HNVoteDirection) -> String {
        return "\(direction.rawValue)_\(id)"
    }
    
    private func vote(id: Int, direction: HNVoteDirection, authToken: String) async throws {
        let voteURL = HNURL.HackerNews.vote.url
            .appending(queryItems: [
                URLQueryItem(name: "id", value: "\(id)"),
                URLQueryItem(name: "how", value: "\(direction.rawValue)"),
                URLQueryItem(name: "auth", value: "\(authToken)"),
            ])

        let (_, _) = try await URLSession.shared.data(from: voteURL)
    }
    
    private func voted(id: Int, direction: HNVoteDirection) async throws -> Bool {
        guard signedIn() else {
            throw VoteError.notSignedIn
        }
        
        guard let html = try await htmlForItem(id: id) else {
            throw VoteError.couldNotConvertItemPage
        }
        
        do {
            return try voted(id: id, direction: direction, html: html)
        } catch {
            throw VoteError.couldNotCheckAnchor
        }
    }
    
    // MARK: - HTML
    
    private func htmlForItem(id: Int) async throws -> String? {
        let itemURL = HNURL.website
            .appendingPathComponent("item")
            .appending(queryItems: [
                URLQueryItem(name: "id", value: "\(id)")
            ])
        
        let (data, _) = try await URLSession.shared.data(from: itemURL)

        guard let html = String(data: data, encoding: .utf8) else {
            return nil
        }
    
        return html
    }
    
    private func authToken(anchorId: String, html: String) throws -> String? {
        let document = try SwiftSoup.parse(html)
        let anchor = try document.select("a#\(anchorId)").first()
        let href = try anchor?.attr("href")
        let components = href?.components(separatedBy: "&")
        let auth = components?.first(where: { $0.hasPrefix("auth=") })?.replacingOccurrences(of: "auth=", with: "")

        return auth
    }
    
    private func voted(id: Int, direction: HNVoteDirection, html: String) throws -> Bool {
        let document = try SwiftSoup.parse(html)
        let anchor = try document.select("a#\(direction)_\(id)").first()

        return anchor != nil
    }
    
    private func checkCaptchaVerificationNeeded(html: String) throws {
        let document = try SwiftSoup.parse(html)
        let validation = try document.select(".g-recaptcha").first()

        guard validation == nil else {
            throw SignInError.captchaVerificationNeeded
        }
    }
}
