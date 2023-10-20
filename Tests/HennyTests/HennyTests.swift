import Foundation

struct HennyTests {
    static let validItemIds = [1, 1232, 272, 484, 457]
    static let invalidItemIds = [-1231231231, 12312321123312, -12122112, 1912212312312, 912912381283218]
    
    static let validUsernames = ["dang", "Phoqe", "0xPersona", "pseudolus", "mikece"]
    static let invalidUsernames = ["u912d9j812j9d21", "9k21d9kd", "102i09d1kd921k90d", "91912d8j9d12j891d2j89", "89jd12d81"]
    
    static let invalidUsername = "92d190kd192dk019dk0921kd"
    static let invalidPassword = "aowkd09j12d9k218dj192j81d2"
    
    static let validUsername = "hackr-test"
    static let validPassword = "hackr123"

    static let urlWithMetadata = URL(string: "https://www.apple.com")!
}
