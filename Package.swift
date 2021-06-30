// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "ModernRIBs",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "ModernRIBs", targets: ["ModernRIBs"]),
    ],
    targets: [
        .target(
            name: "ModernRIBs",
            path: "ModernRIBs",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "ModernRIBsTests",
            dependencies: ["ModernRIBs"],
            path: "ModernRIBsTests",
            exclude: ["Info.plist"]
        ),
    ]
)
