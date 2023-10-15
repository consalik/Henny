import Foundation

public struct HNUserSettings {
    public let email: String?
    
    public let showDead: Bool
    
    public let noProcrast: Bool
    public let maxVisit: Int
    public let minAway: Int
    
    public let delay: Int
    
    public func httpBody(username: String, hmac: String) -> String? {
        var components = URLComponents()
        
        components.queryItems = [
            URLQueryItem(name: "id", value: username),
            URLQueryItem(name: "hmac", value: hmac),
            URLQueryItem(name: "about", value: "This is a bio."),
            URLQueryItem(name: "email", value: email ?? ""),
            URLQueryItem(name: "showd", value: showDead ? "yes" : "no"),
            URLQueryItem(name: "nopro", value: noProcrast ? "yes" : "no"),
            URLQueryItem(name: "maxv", value: "\(maxVisit)"),
            URLQueryItem(name: "mina", value: "\(minAway)"),
            URLQueryItem(name: "delay", value: "\(delay)")
        ]

        return components.percentEncodedQuery
    }
}
