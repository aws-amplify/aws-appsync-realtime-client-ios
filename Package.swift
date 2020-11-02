// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppSyncRealTimeClient",
    products: [
        .library(
            name: "AppSyncRealTimeClient",
            targets: ["AppSyncRealTimeClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream", .upToNextMinor(from: "3.1.1"))
    ],
    targets: [
        .target(
            name: "AppSyncRealTimeClient",
            dependencies: ["Starscream"],
            path: "AppSyncRealTimeClient"
        ),
        .testTarget(
            name: "AppSyncRealTimeClientTests",
            dependencies: ["AppSyncRealTimeClient"],
            path: "AppSyncRealTimeClientTests"
        )
    ]
)
