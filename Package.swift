// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let volkCDefine: [CSetting] = [
    .define("VK_USE_PLATFORM_WAYLAND_KHR", .when(platforms: [.linux])),
]

let vmaCDefine: [CSetting] = [
    .define("VK_NO_PROTOTYPES")
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

        .target(
            name: "CVMA",
            cSettings: vmaCDefine,
        ),

        .target(
            name: "CVolk",
            cSettings: [] + volkCDefine,
        ),

        .executableTarget(
            name: "graphics-101",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .target(name: "Wayland", condition: .when(platforms: [.linux])),
                "CVolk",
                "CVMA",
            ],
            cSettings: [] + volkCDefine + vmaCDefine,
        ),
    ]
)
