// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STCatalog",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "STCatalog",
            targets: ["STCatalog"]),
    ],
    dependencies: [
        .package(path: "../STCore_iOS"),
        .package(path: "../STBlueSDK_iOS"),
        .package(path: "../STUI_iOS"),
        .package(path: "../STDemos_iOS"),
        .package(url: "https://github.com/youtube/youtube-ios-player-helper.git", from: Version(1, 0, 0)),
        .package(url: "https://github.com/ElaWorkshop/TagListView.git", from: Version(1, 4, 1))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "STCatalog",
            dependencies: [
                .product(name: "STCore", package: "STCore_iOS"),
                .product(name: "STUI", package: "STUI_iOS"),
                .product(name: "STBlueSDK", package: "STBlueSDK_iOS"),
                .product(name: "STDemos", package: "STDemos_iOS"),
                .product(name: "YouTubeiOSPlayerHelper", package: "youtube-ios-player-helper"),
                .product(name: "TagListView", package: "TagListView")
            ]),
        .testTarget(
            name: "STCatalogTests",
            dependencies: ["STCatalog"]),
    ]
)
