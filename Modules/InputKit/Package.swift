// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InputKit",
    products: [
        .library(
            name: "InputKit",
            targets: ["InputKit"]
        )
    ],
    dependencies: [
        .package(name: "ObservationToken", path: "../ObservationToken")
    ],
    targets: [
        .target(
            name: "InputKitC",
            dependencies: []
        ),
        .target(
            name: "InputKit",
            dependencies: [
                "InputKitC",
                "ObservationToken"
            ]
        ),
        .testTarget(
            name: "InputKitTests",
            dependencies: ["InputKit"]
        )
    ]
)
