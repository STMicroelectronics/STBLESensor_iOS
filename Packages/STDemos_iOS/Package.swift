// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STDemos",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
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
         .package(url: "https://github.com/danielgindi/Charts.git", from: Version(5, 1, 0)),
         .package(url: "https://github.com/emqx/CocoaMQTT.git", branch: "master")
         
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
                .product(name: "DGCharts", package: "Charts"),
                .product(name: "CocoaMQTT", package: "CocoaMQTT")
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Environmental/EnviromentalView.xib"),
                .process("Environmental/SensorView.xib"),
                .process("PnpL/PnpLView.xib"),
                .process("Flow/Json/counter_flows.json"),
                .process("Flow/Json/exp_flows.json"),
                .process("Flow/Json/filters.json"),
                .process("Flow/Json/functions.json"),
                .process("Flow/Json/output.json"),
                .process("Flow/Json/sensors.json"),
                .process("Flow/Json/Examples/Vibration monitor - Training.json"),
                .process("Flow/Json/Examples/Vibration monitor - Compare.json"),
                .process("Flow/Json/Examples/SensorFusionCube_pro.json"),
                .process("Flow/Json/Examples/SensorFusionCube.json"),
                .process("Flow/Json/Examples/Q-Touch.json"),
                .process("Flow/Json/Examples/Pedometer_pro.json"),
                .process("Flow/Json/Examples/Pedometer.json"),
                .process("Flow/Json/Examples/NFC Writer.json"),
                .process("Flow/Json/Examples/Level_pro.json"),
                .process("Flow/Json/Examples/Level.json"),
                .process("Flow/Json/Examples/In-Vehicle Baby Alarm_pro.json"),
                .process("Flow/Json/Examples/In-Vehicle Baby Alarm.json"),
                .process("Flow/Json/Examples/Human Activity recognition_pro.json"),
                .process("Flow/Json/Examples/Human Activity recognition.json"),
                .process("Flow/Json/Examples/Free-Fall detector_pro.json"),
                .process("Flow/Json/Examples/Data recorder_pro.json"),
                .process("Flow/Json/Examples/Data recorder.json"),
                .process("Flow/Json/Examples/Compass_pro.json"),
                .process("Flow/Json/Examples/Compass.json"),
                .process("Flow/Json/Examples/Barometer_pro.json"),
                .process("Flow/Json/Examples/Barometer.json"),
                .process("Flow/Json/Examples/Baby Crying Detector.json")
            ]),
        .testTarget(
            name: "STDemosTests",
            dependencies: ["STDemos"]),
    ]
)
