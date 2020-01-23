// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "StringSearch",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "StringSearch",
                 targets: ["StringSearch"]),
    ],
    targets: [
        .target(name: "StringSearch"),
        .testTarget(name: "StringSearchTests",
                    dependencies: ["StringSearch"]),
    ]
)
