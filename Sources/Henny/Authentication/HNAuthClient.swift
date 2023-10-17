import Foundation
import SwiftSoup

public struct HNAuthClient {
    
    public static let shared = HNAuthClient()
    
    // MARK: - Lifecycle
    
    ///
    /// Signs the user in using the provided username and password.
    /// It signs the user in by making a POST request to the login page with the provided credentials.
    /// It then checks if the user is signed in by checking if the `user` cookie is present.
    /// 
    /// - Throws: `SignInError.alreadySignedIn` if the user is already signed in.
    /// - Throws: `SignInError.invalidResponse` if the response from the server could not be converted to a string.
    /// - Throws: `SignInError.invalidCredentials` if the credentials are invalid.
    /// - Throws: `SignInError.captchaVerificationNeeded` if the server requires the user to verify that they are not a robot.
    ///
    public func signIn(username: String, password: String) async throws {
        guard !signedIn() else {
            throw SignInError.alreadySignedIn
        }
        
        let request = signInRequest(acct: username, pw: password)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw SignInError.invalidResponse
        }
        
        guard !captcha(html: html) else {
            throw SignInError.captchaVerificationNeeded
        }
        
        guard signedIn() else {
            throw SignInError.invalidCredentials
        }
    }
    
    /// Whether the user is signed in based on the presence of the `user` cookie.
    public func signedIn() -> Bool {
        cookie(named: "user") != nil
    }
    
    /// Signs the user out by removing all the cookies including the `user` cookie.
    public func signOut() {
        removeAllCookies()
    }
    
    // MARK: - User
    
    /// The username of the signed in user.
    /// Returns `nil` if the user is not signed in.
    public func username() -> String? {
        extractUsernameFromCookie()
    }
    
    public func userSettings() async throws -> HNUserSettings {
        guard signedIn() else {
            throw UserSettingsError.notSignedIn
        }
        
        guard let username = username() else {
            throw UserSettingsError.invalidUserSettings // TODO
        }
        
        guard let html = try await fetchHtml(from: HNURL.Website.user(id: username)) else {
            throw UserSettingsError.couldNotConvertUserPage
        }
        
        guard let userSettings = userSettings(html: html) else {
            throw UserSettingsError.invalidUserSettings
        }
        
        return userSettings
    }
    
    // MARK: - Voting
    
    public func vote(id: Int, direction: HNVoteDirection) async throws {
        guard signedIn() else {
            throw VoteError.notSignedIn
        }
        
        guard let html = try await fetchHtml(from: HNURL.Website.item(id: id)) else {
            throw VoteError.couldNotConvertItemPage
        }
        
        let anchorId = anchorId(id: id, direction: direction)
        
        guard let authToken = extractAuthToken(from: html, anchorId: anchorId) else {
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
    
    // MARK: - Submissions
    
    public func submit(title: String, url: URL?, text: String?) async throws {
        guard signedIn() else {
            throw SubmitError.notSignedIn
        }
        
        guard let html = try await fetchHtml(from: HNURL.HackerNews.submit.url) else {
            throw SubmitError.couldNotConvertSubmitPage
        }
        
        guard let fnId = fnId(html: html) else {
            throw SubmitError.invalidFnId
        }
        
        guard let fnOp = fnOp(html: html) else {
            throw SubmitError.invalidFnOp
        }
        
        let submission = HNSubmission(fnId: fnId, fnOp: fnOp, title: title, url: url, text: text)
        let request = submitRequest(submission: submission)
        let (data, response) = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Helpers

    private func fetchHtml(from url: URL) async throws -> String? {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let html = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return html
    }
    
    private func anchorId(id: Int, direction: HNVoteDirection) -> String {
        return "\(direction.rawValue)_\(id)"
    }
    
    private func vote(id: Int, direction: HNVoteDirection, authToken: String) async throws {
        let voteURL = HNURL.Website.vote(id: id, how: direction.rawValue, auth: authToken)
        let (_, _) = try await URLSession.shared.data(from: voteURL)
    }
    
    private func voted(id: Int, direction: HNVoteDirection) async throws -> Bool {
        guard signedIn() else {
            throw VoteError.notSignedIn
        }
        
        guard let html = try await fetchHtml(from: HNURL.Website.item(id: id)) else {
            throw VoteError.couldNotConvertItemPage
        }
        
        return voted(id: id, direction: direction, html: html)
    }
    
    // MARK: - Cookies
    
    private func cookie(named name: String) -> HTTPCookie? {
        let cookies = HTTPCookieStorage.shared.cookies(for: HNURL.HackerNews.login.url) ?? []
        return cookies.first { $0.name == name }
    }
    
    private func extractUsernameFromCookie() -> String? {
        guard let userCookieValue = cookie(named: "user")?.value,
              let username = userCookieValue.split(separator: "&").first else {
            return nil
        }
        
        return String(username)
    }
    
    private func removeAllCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies(for: HNURL.HackerNews.login.url) {
            cookies.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        }
    }
    
    // MARK: - Requests
    
    private func signInRequest(acct: String, pw: String) -> URLRequest {
        var request = URLRequest(url: HNURL.HackerNews.login.url)
        let body = "acct=\(acct)&pw=\(pw)"

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        return request
    }

    private func submitRequest(submission: HNSubmission) -> URLRequest {
        var request = URLRequest(url: HNURL.HackerNews.r.url)

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = submission.httpBody

        return request
    }
    
    // MARK: - HTML
    
    private func extractAuthToken(from html: String, anchorId: String) -> String? {
        let document = try? SwiftSoup.parse(html)
        let anchor = try? document?.select("a#\(anchorId)").first()
        let href = try? anchor?.attr("href")
        let components = href?.components(separatedBy: "&")
        let auth = components?.first(where: { $0.hasPrefix("auth=") })?.replacingOccurrences(of: "auth=", with: "")

        return auth
    }
    
    private func voted(id: Int, direction: HNVoteDirection, html: String) -> Bool {
        let document = try? SwiftSoup.parse(html)
        let anchor = try? document?.select("a#\(direction)_\(id)").first()

        return anchor != nil
    }
    
    private func captcha(html: String) -> Bool {
        let document = try? SwiftSoup.parse(html)
        let validation = try? document?.select(".g-recaptcha").first()
        
        return validation != nil
    }
    
    private func userSettings(html: String) -> HNUserSettings? {
        let document = try? SwiftSoup.parse(html)
        
        let email = try? document?.select("input[name=email]").first()?.`val`()

        guard let showdeadStr = try? document?.select("select[name=showd] option[selected]").first()?.text(),
              let noprocrastStr = try? document?.select("select[name=nopro] option[selected]").first()?.text(),
              let maxvisitStr = try? document?.select("input[name=maxv]").first()?.`val`(),
              let minawayStr = try? document?.select("input[name=mina]").first()?.`val`(),
              let delayStr = try? document?.select("input[name=delay]").first()?.`val`(),
              let maxvisit = Int(maxvisitStr),
              let minaway = Int(minawayStr),
              let delay = Int(delayStr) else {
            return nil
        }
        
        let showdead = showdeadStr.lowercased() == "yes"
        let noprocrast = noprocrastStr.lowercased() == "yes"
        
        return HNUserSettings(
            email: email,
            showDead: showdead,
            noProcrast: noprocrast,
            maxVisit: maxvisit,
            minAway: minaway,
            delay: delay
        )
    }
    
    private func hmac(html: String) -> String? {
        let document = try? SwiftSoup.parse(html)
        let hmac = try? document?.select("input[name=hmac]").first()?.`val`()

        return hmac
    }
    
    private func fnId(html: String) -> String? {
        let document = try? SwiftSoup.parse(html)
        let hmac = try? document?.select("input[name=fnid]").first()?.`val`()

        return hmac
    }
    
    private func fnOp(html: String) -> String? {
        let document = try? SwiftSoup.parse(html)
        let hmac = try? document?.select("input[name=fnop]").first()?.`val`()

        return hmac
    }
}
