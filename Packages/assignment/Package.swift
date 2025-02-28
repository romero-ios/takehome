// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "assignment",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "AppFeature",targets: ["AppFeature"]),
        .library(name: "BirdDetailFeature",targets: ["BirdDetailFeature"]),
        .library(name: "AddNoteFeature",targets: ["AddNoteFeature"]),
        .library(name: "Navigation",targets: ["Navigation"]),
        .library(name: "BirdsRepository",targets: ["BirdsRepository"]),
        .library(name: "APIClient",targets: ["APIClient"]),
        .library(name: "WatermarkClient",targets: ["WatermarkClient"]),
        .library(name: "Models",targets: ["Models"]),
        .library(name: "UserInterface",targets: ["UserInterface"]),
        .library(name: "KingFisherExtension",targets: ["KingFisherExtension"])
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.15.2"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "BirdDetailFeature",
                "AddNoteFeature",
                "Navigation",
                "BirdsRepository",
                "Models",
                "UserInterface"
            ]
        ),
        .target(
            name: "BirdDetailFeature",
            dependencies: [
                "BirdsRepository",
                "Models",
                "UserInterface"
            ]
        ),
        .target(
            name: "AddNoteFeature",
            dependencies: [
                "BirdsRepository",
                "Models",
                "UserInterface"
            ]
        ),
        .target(
            name: "BirdsRepository",
            dependencies: [
                "Models",
                "APIClient"
            ]
        ),
        .target(
            name: "Navigation"
        ),
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios")
            ]
        ),
        .target(
            name: "WatermarkClient"
        ),
        .target(
            name: "Models"
        ),
        .target(
            name: "UserInterface",
            dependencies: [
                "KingFisherExtension"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "KingFisherExtension",
            dependencies: [
                "Kingfisher",
                "WatermarkClient"
            ]
        )
    ]
)
