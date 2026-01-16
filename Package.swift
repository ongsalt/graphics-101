// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "graphics-101",
    products: [
        .library(name: "CWayland", targets: ["CWayland"]),
    ],
    targets: [
        .systemLibrary(name: "CWayland"),
        .target(name: "Wayland", dependencies: ["CWayland"]),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "graphics-101",
            dependencies: ["Wayland"],
            swiftSettings: []
        ),
    ]
)
