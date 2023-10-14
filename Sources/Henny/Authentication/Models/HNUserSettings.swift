import Foundation

public struct HNUserSettings {
    public let email: String?
    
    public let showDead: Bool
    
    public let limitVisits: Bool // noprocrast
    public let browsingDuration: Int // maxvisit
    public let coolOffInterval: Int // minaway
    
    public let commentEditWindow: Int // delay
}
