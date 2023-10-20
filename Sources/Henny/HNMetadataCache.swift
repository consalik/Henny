import Foundation
import LinkPresentation

struct HNMetadataCache {
    
    private let fileManager = FileManager.default
    
    private func fileURL(for url: URL) throws -> URL {
        let fileName = url.absoluteString.hashValue
        let fileNameString = String(fileName)
        
        return try fileManager
            .url(for: .cachesDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: false)
            .appendingPathComponent("HNMetadataCache")
            .appendingPathComponent(fileNameString)
    }
    
    func set(_ metadata: LPLinkMetadata, for url: URL) throws {
        let fileURL = try fileURL(for: url)
        let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
        
        try data.write(to: fileURL)
    }

    func metadata(for url: URL) throws -> LPLinkMetadata? {
        let fileURL = try fileURL(for: url)
        let data = try Data(contentsOf: fileURL)
        let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data)
        
        return metadata
    }
}
