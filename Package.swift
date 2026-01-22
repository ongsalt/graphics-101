// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "graphics-101",
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(name: "CWayland"),
        .target(
            name: "Wayland",
            dependencies: ["CWayland"],
            swiftSettings: [
                .interoperabilityMode(.C)
            ]
        ),

        .target(name: "CVMA"),

        .target(
            name: "CVolk",
        ),

        .executableTarget(
            name: "graphics-101",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                "Wayland",
                "CVMA",
                "CVolk",
            ],
            swiftSettings: [
            ]
        ),
    ]
)
