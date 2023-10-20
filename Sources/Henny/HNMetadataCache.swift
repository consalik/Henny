import Foundation
import LinkPresentation
import OSLog
import CryptoKit

struct HNMetadataCache {
    
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: HNMetadataCache.self))
    
    private func cacheDirectoryURL() throws -> URL {
        do {
            let directoryURL = try fileManager
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("HNMetadataCache")
            
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            return directoryURL
        } catch {
            logger.error("Failed to get cache directory URL: \(error.localizedDescription)")
            
            throw error
        }
    }
    
    private func fileName(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let digest = Insecure.SHA1.hash(data: data)
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func fileURL(for url: URL) throws -> URL {
        do {
            let cacheDirectoryURL = try cacheDirectoryURL()
            let fileName = fileName(for: url)
            
            return cacheDirectoryURL
                .appendingPathComponent(fileName)
        } catch {
            logger.error("Failed to get file URL for \(url.absoluteString): \(error.localizedDescription)")
            
            throw error
        }
    }
    
    func set(_ metadata: LPLinkMetadata, for url: URL) throws {
        let fileURL = try fileURL(for: url)

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
            try data.write(to: fileURL)
        } catch {
            logger.error("Failed to write metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
    }

    func metadata(for url: URL) throws -> LPLinkMetadata? {
        let fileURL = try fileURL(for: url)

        do {
            let data = try Data(contentsOf: fileURL)
            let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data)

            return metadata
        } catch {
            logger.error("Failed to read metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
    }
}
