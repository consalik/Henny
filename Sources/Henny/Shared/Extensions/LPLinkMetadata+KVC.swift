import Foundation
import LinkPresentation

extension LPLinkMetadata {
    
    var title: String? {
        self.value(forKey: "_title") as? String
    }

    var summary: String? {
        self.value(forKey: "_summary") as? String
    }
    
    var siteName: String? {
        self.value(forKey: "_siteName") as? String
    }
    
    var creator: String? {
        self.value(forKey: "_creator") as? String
    }
    
    var creatorFacebookProfile: String? {
        self.value(forKey: "_creatorFacebookProfile") as? String
    }
    
    var creatorTwitterUsername: String? {
        self.value(forKey: "_creatorTwitterUsername") as? String
    }
    
    var itemType: String? {
        self.value(forKey: "_itemType") as? String
    }
    
    var imageURL: URL? {
        (self.value(forKey: "images") as? [NSObject])?.first?.value(forKey: "_URL") as? URL
    }
}
