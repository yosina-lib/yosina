// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Yosina",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v16),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "Yosina",
            targets: ["Yosina"]
        ),
    ],
    targets: [
        .target(
            name: "Yosina",
            resources: [
                .copy("Resources/ivs_svs_base.data"),
            ]
        ),
        .testTarget(
            name: "YosinaTests",
            dependencies: ["Yosina"]
        ),
    ]
)
