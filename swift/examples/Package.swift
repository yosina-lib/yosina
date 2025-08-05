// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YosinaExamples",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "BasicUsage", targets: ["BasicUsage"]),
        .executable(name: "ConfigBasedUsage", targets: ["ConfigBasedUsage"]),
        .executable(name: "AdvancedUsage", targets: ["AdvancedUsage"]),
    ],
    dependencies: [
        .package(name: "yosina", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "BasicUsage",
            dependencies: [
                .product(name: "Yosina", package: "yosina"),
            ],
            path: "Sources",
            sources: ["BasicUsage.swift"]
        ),
        .executableTarget(
            name: "ConfigBasedUsage",
            dependencies: [
                .product(name: "Yosina", package: "yosina"),
            ],
            path: "Sources",
            sources: ["ConfigBasedUsage.swift"]
        ),
        .executableTarget(
            name: "AdvancedUsage",
            dependencies: [
                .product(name: "Yosina", package: "yosina"),
            ],
            path: "Sources",
            sources: ["AdvancedUsage.swift"]
        ),
    ]
)
