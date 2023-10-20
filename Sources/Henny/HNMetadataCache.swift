import Foundation
import LinkPresentation
import OSLog
import CryptoKit

struct HNMetadataCache {
    
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: HNMetadataCache.self))
    
    // MARK: - Settings
    
    private let metadataLifetime: TimeInterval
    private let maxCacheSize: UInt64
    private let cacheDirectoryName: String

    init(
        metadataLifetime: TimeInterval = 86_400, // 24 hours
        maxCacheSize: UInt64 = 1024 * 1024 * 100, // 100 MB
        cacheDirectoryName: String = String(describing: HNMetadataCache.self)
    ) {
        self.metadataLifetime = metadataLifetime
        self.maxCacheSize = maxCacheSize
        self.cacheDirectoryName = cacheDirectoryName
    }
    
    // MARK: - Expiry
    
    private func metadataExpired(atPath path: String) -> Bool {
        guard let attributes = try? fileManager.attributesOfItem(atPath: path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return true
        }
        
        return Date.now.timeIntervalSince(modificationDate) > metadataLifetime
    }
    
    // MARK: - Size
    
    private func clearCacheIfNeeded() throws {
        let cacheDirectoryURL = try cacheDirectoryURL()
        let contents = try fileManager.contentsOfDirectory(atPath: cacheDirectoryURL.path)
        var totalSize: UInt64 = 0
        var filesAndAttributes = [(url: URL, size: UInt64, lastAccessDate: Date)]()
        
        for filename in contents {
            let fileURL = cacheDirectoryURL.appendingPathComponent(filename)
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            
            if let fileSize = attributes[.size] as? UInt64,
               let modificationDate = attributes[.modificationDate] as? Date {
                totalSize += fileSize
                filesAndAttributes.append((url: fileURL, size: fileSize, lastAccessDate: modificationDate))
            }
        }
        
        if totalSize > maxCacheSize {
            filesAndAttributes.sort { $0.lastAccessDate < $1.lastAccessDate }
            
            for file in filesAndAttributes {
                try fileManager.removeItem(at: file.url)
                
                totalSize -= file.size
                
                if totalSize <= maxCacheSize {
                    break
                }
            }
        }
    }
    
    // MARK: - URLs
    
    private func cacheDirectoryURL() throws -> URL {
        do {
            let directoryURL = try fileManager
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(cacheDirectoryName)
            
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
    
    // MARK: - Lifecycle
    
    func set(_ metadata: LPLinkMetadata, for url: URL) throws {
        let fileURL = try fileURL(for: url)

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
            try data.write(to: fileURL)
            try clearCacheIfNeeded()
        } catch {
            logger.error("Failed to write metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
    }

    func metadata(for url: URL) throws -> LPLinkMetadata? {
        let fileURL = try fileURL(for: url)

        guard fileManager.fileExists(atPath: fileURL.path),
              !metadataExpired(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data)

            return metadata
        } catch {
            logger.error("Failed to read metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
    }

    func clear() throws {
        do {
            let cacheDirectoryURL = try cacheDirectoryURL()
            let contents = try fileManager.contentsOfDirectory(atPath: cacheDirectoryURL.path)

            for filename in contents {
                let fileURL = cacheDirectoryURL.appendingPathComponent(filename)

                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            logger.error("Failed to clear cache: \(error.localizedDescription)")

            throw error
        }
    }
}
