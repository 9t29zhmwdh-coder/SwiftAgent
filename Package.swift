// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EmissaryKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "EmissaryKit",
            targets: ["EmissaryKit"]
        ),
    ],
    targets: [
        .target(
            name: "EmissaryKit",
            path: "Sources/EmissaryKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "EmissaryKitTests",
            dependencies: ["EmissaryKit"],
            path: "Tests/EmissaryKitTests"
        ),
    ]
)
