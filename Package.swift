// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let volkCDefine: [CSetting] = [
    .define("VK_USE_PLATFORM_WAYLAND_KHR", .when(platforms: [.linux])),
    // .define("VOLK_IMPLEMENTATION"),
    .define("VK_VERSION_1_0"),
    .define("VK_VERSION_1_1"),
    .define("VK_VERSION_1_2"),
    .define("VK_VERSION_1_3"),
]

let package = Package(
    name: "graphics-101",
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")
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
            cSettings: [] + volkCDefine,
            swiftSettings: [],
        ),

        .executableTarget(
            name: "graphics-101",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .target(name: "Wayland", condition: .when(platforms: [.linux])),
                // "CVMA",
                "CVolk",
            ],
            cSettings: [] + volkCDefine,
        ),
    ]
)
