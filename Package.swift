// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ModernRIBs",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(name: "ModernRIBs", targets: ["ModernRIBs"]),
    ],
    targets: [
        .target(
            name: "ModernRIBs",
            path: "ModernRIBs"
        ),
        .testTarget(
            name: "ModernRIBsTests",
            dependencies: ["ModernRIBs"],
            path: "ModernRIBsTests"
        ),
    ]
)
