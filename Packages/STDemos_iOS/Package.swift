// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STDemos",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "STDemos",
            targets: ["STDemos"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(path: "../STCore_iOS"),
         .package(path: "../STBlueSDK_iOS"),
         .package(path: "../STUI_iOS"),
         .package(url: "https://github.com/core-plot/core-plot", branch: "release-2.4"),
         .package(url: "https://github.com/scalessec/Toast-Swift", branch: "master"),
         .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", from: Version(2, 2, 0)),
         .package(url: "https://github.com/danielgindi/Charts.git", .upToNextMajor(from: "4.1.0"))
         
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "STDemos",
            dependencies: [
                .product(name: "STCore", package: "STCore_iOS"),
                .product(name: "STUI", package: "STUI_iOS"),
                .product(name: "STBlueSDK", package: "STBlueSDK_iOS"),
                .product(name: "CorePlot", package: "core-plot"),
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "JGProgressHUD", package: "JGProgressHUD"),
                .product(name: "Charts", package: "Charts"),
            ],
            resources: [
                .copy("Resources/Assets.xcassets"),
                .copy("Environmental/EnviromentalView.xib"),
                .copy("Environmental/SensorView.xib"),
                .copy("PnpL/PnpLView.xib")
            ]),
        .testTarget(
            name: "STDemosTests",
            dependencies: ["STDemos"]),
    ]
)
