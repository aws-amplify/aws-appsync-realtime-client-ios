// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let platforms: [SupportedPlatform] = [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v9)
]

let package = Package(
    name: "AppSyncRealTimeClient",
    platforms: platforms,
    products: [
        .library(
            name: "AppSyncRealTimeClient",
            targets: ["AppSyncRealTimeClient"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AppSyncRealTimeClient",
            path: "AppSyncRealTimeClient",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "AppSyncRealTimeClientTests",
            dependencies: ["AppSyncRealTimeClient"],
            path: "AppSyncRealTimeClientTests",
            exclude: ["Info.plist"]
        )
    ]
)
