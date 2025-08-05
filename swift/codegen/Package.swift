// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YosinaCodegen",
    platforms: [.macOS(.v12)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "YosinaCodegen",
            path: "Sources"
        ),
    ]
)
