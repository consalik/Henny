import Foundation

struct HNSubmission {
    public let fnId: String
    public let fnOp: String
    
    public let title: String
    public let url: URL?
    public let text: String?
    
    public init(fnId: String, fnOp: String, title: String, url: URL?, text: String?) {
        self.fnId = fnId
        self.fnOp = fnOp
        self.title = title
        self.url = url
        self.text = text
    }
}

extension HNSubmission {
    var httpBody: Data? {
        let urlValue = url?.absoluteString ?? ""
        let textValue = text ?? ""
        let body = "fnid=\(fnId)&fnop=\(fnOp)&title=\(title)&url=\(urlValue)&text=\(textValue)"
        
        return body.data(using: .utf8)
    }
}
