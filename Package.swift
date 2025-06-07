// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "claude-yes",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "claude-yes",
            targets: ["ClaudeYes"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ClaudeYes",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ClaudeYesTests",
            dependencies: ["ClaudeYes"],
            path: "Tests"
        )
    ]
)