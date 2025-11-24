// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavRouter",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "NavRouter",
            targets: ["NavRouter"]
        ),
    ],
    targets: [
        .target(
            name: "NavRouter"
        ),
        .testTarget(
            name: "NavRouterTests",
            dependencies: ["NavRouter"]
        ),
    ]
)
