import Foundation
import LinkPresentation
import OSLog

struct HNMetadataCache {
    
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: HNMetadataCache.self))
    
//    private func cacheDirectoryURL() throws -> URL {
//        let directoryURL = try fileManager
//            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            .appendingPathComponent("HNMetadataCache")
//    }
    
    private func fileURL(for url: URL) throws -> URL {
        let fileName = url.absoluteString.hashValue
        let fileNameString = String(fileName)
        
        do {
            return try fileManager
                .url(for: .cachesDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true)
                .appendingPathComponent("HNMetadataCache")
                .appendingPathComponent(fileNameString)
        } catch {
            logger.error("Failed to get file URL for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
    }
    
    func set(_ metadata: LPLinkMetadata, for url: URL) throws {
        let fileURL = try fileURL(for: url)
        var data: Data?

        do {
            data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
        } catch {
            logger.error("Failed to archive metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
        
        guard let data else {
            logger.error("Failed to archive metadata for \(url.absoluteString)")

            return
        }
        
        do {
            try data.write(to: fileURL)
        } catch {
            logger.error("Failed to write metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }
    }

    func metadata(for url: URL) throws -> LPLinkMetadata? {
        let fileURL = try fileURL(for: url)
        var data: Data?

        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            logger.error("Failed to read metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }

        guard let data else {
            logger.error("Failed to read metadata for \(url.absoluteString)")

            return nil
        }

        var metadata: LPLinkMetadata?

        do {
            metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data)
        } catch {
            logger.error("Failed to unarchive metadata for \(url.absoluteString): \(error.localizedDescription)")

            throw error
        }

        guard let metadata else {
            logger.error("Failed to unarchive metadata for \(url.absoluteString)")

            return nil
        }
        
        return metadata
    }
}
