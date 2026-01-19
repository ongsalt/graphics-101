// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "graphics-101",
    targets: [
        .target(name: "CWayland"),
        .systemLibrary(name: "CVulkan", pkgConfig: "vulkan"),
        .target(name: "Wayland", dependencies: ["CWayland"]),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "graphics-101",
            dependencies: ["Wayland", "CVulkan"],
            swiftSettings: [
                // .interoperabilityMode(.Cxx)
            ]
        ),
    ]
)
