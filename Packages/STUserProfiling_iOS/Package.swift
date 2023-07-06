// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STUserProfiling",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "STUserProfiling",
            targets: ["STUserProfiling"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../STUI_iOS"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "STUserProfiling",
            dependencies: [
                .product(name: "STUI", package: "STUI_iOS"),
            ],
            resources: [
                .copy("Resources/OptionView.xib"),
                .copy("Resources/UserProfilingView.xib")
            ]),
        .testTarget(
            name: "STUserProfilingTests",
            dependencies: ["STUserProfiling"]),
    ]
)
