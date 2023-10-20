import XCTest
import LinkPresentation

@testable import Henny

final class HNMetadataCacheTests: XCTestCase {
    
    var metadataCache: HNMetadataCache!
    
    override func setUp() async throws {
        metadataCache = HNMetadataCache(
            metadataLifetime: 5,
            maxCacheSize: 1024
        )
    }
    
    // MARK: - Metadata

    func testShouldNotReturnMetadataForNonCachedURL() throws {
        let metadata = try metadataCache.metadata(for: HennyTests.urlWithMetadata)

        XCTAssertNil(metadata)
    }

    func testShouldReturnMetadataForCachedURL() throws {
        let metadata = LPLinkMetadata()
        
        try metadataCache.set(metadata, for: HennyTests.urlWithMetadata)

        let cachedMetadata = try metadataCache.metadata(for: HennyTests.urlWithMetadata)

        XCTAssertNotNil(cachedMetadata)
    }
    
    // MARK: - Expiry

    func testShouldNotReturnMetadataForExpiredURL() async throws {
        let metadata = LPLinkMetadata()
        
        try metadataCache.set(metadata, for: HennyTests.urlWithMetadata)

        try await Task.sleep(nanoseconds: 6 * 1_000_000_000)

        let cachedMetadata = try metadataCache.metadata(for: HennyTests.urlWithMetadata)

        XCTAssertNil(cachedMetadata)
    }

    // MARK: - Size

    func testShouldEvictLeastRecentlyUsedMetadataWhenCacheSizeIsExceeded() async throws {
        let metadata = LPLinkMetadata()

        for i in 0..<5 {
            try metadataCache.set(metadata, for: URL(string: "https://www.apple.com/\(i)")!)
        }

        let cachedMetadata = try metadataCache.metadata(for: URL(string: "https://www.apple.com/0")!)

        XCTAssertNil(cachedMetadata)
    }
}
