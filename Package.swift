// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spm",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.4.0"),
        .package(url: "https://github.com/nvzqz/FileKit.git", exact: "6.1.0"),
        .package(url: "https://github.com/onevcat/Rainbow.git", exact: "4.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "spm",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FileKit", package: "FileKit"),
                .product(name: "Rainbow", package: "Rainbow")
            ]
        ),
    ]
)
