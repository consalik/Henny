// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Henny",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v12),
        .driverKit(.v19),
        .macCatalyst(.v13),
        .visionOS(.v1),
        .watchOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Henny",
            targets: ["Henny"]
        ),
    ],
    dependencies: [
      .package(
        url: "https://github.com/firebase/firebase-ios-sdk.git",
        .upToNextMajor(from: "10.16.0")
      ),
      .package(
        url: "https://github.com/scinfu/SwiftSoup.git",
        .upToNextMajor(from: "2.6.1")
      ),
      .package(
        url: "https://github.com/algolia/algoliasearch-client-swift",
        .upToNextMajor(from: "8.18.2")
      )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Henny",
            dependencies: [
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabaseSwift", package: "firebase-ios-sdk"),
                "SwiftSoup",
                .product(name: "AlgoliaSearchClient", package: "algoliasearch-client-swift")
            ]
        ),
        .testTarget(
            name: "HennyTests",
            dependencies: ["Henny"]
        ),
    ]
)
