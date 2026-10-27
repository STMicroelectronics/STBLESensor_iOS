//
//  Demo+SwiftUIViews.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK

/// Single source of truth for which demos have a native SwiftUI implementation.
/// `DemoListView` renders this view when available, and falls back to the legacy
/// `DemoPresenterWrapper` (UIKit) otherwise. To migrate a demo: implement its SwiftUI
/// view, then add one case here — nothing else needs to change.
public extension Demo {
    func swiftUIView(node: Node) -> AnyView? {
        switch self {
        case .environmental:
            return AnyView(EnvironmentalDemoView(node: node))
        case .plot:
            return AnyView(PlotDemoView(node: node))
            //        case .fft:
            //        case .neaiAnomalyDetection:
            //        case .neaiClassification:
            //        case .neaiExtrapolation:
        case .predictiveMaintenance:
            return AnyView(PredictiveMaintenanceDemoView(node: node))
        case .highSpeedDataLog:
            return AnyView(LegacyView())
            //        case .highSpeedDataLog2:
            //        case .pnpLike:
            //        case .extendedConfiguration:
        case .switchDemo:
            return AnyView(SwitchDemoView(node: node))
            //        case .ledControl:
            //            return AnyView(LedControlView(node: node, rssi: param as? Int ?? 0))
            //        case .heartRate:
            //        case .blueVoice:
            //        case .beamforming:
            //        case .audioSourceLocalization:
        case .audioClassification:
            return AnyView(AudioClassificationDemoView(node: node))
            //        case .activityRecognition:
            //        case .multiNN:
        case .machineLearningCore:
            return AnyView(RegisterDemoView(node: node, registerDemoType: .mlc))
        case .finiteStateMachine:
            return AnyView(RegisterDemoView(node: node,registerDemoType: .fsm))
        case .stredl:
            return AnyView(RegisterDemoView(node: node, registerDemoType: .stredl))
            //        case .flow:
        case .eventCounter:
            return AnyView(EventCounterDemoView(node: node))
        case .gestureNavigation:
            return AnyView(GestureNavigationDemoView(node: node))
        case .jsonNfc:
            return AnyView(JsonNfcDemoView(node: node))
            //        case .piano:
        case .pedometer:
            return AnyView(PedometerDemoView(node: node))
        case .level:
            return AnyView(LevelDemoView(node: node))
        case .compass:
            return AnyView(CompassDemoView(node: node))
            //        case .memsSensorFusion:
        case .memsGesture:
            return AnyView(MemsGestureDemoView(node: node))
            //        case .motionAlgorithm:
        case .carryPosition:
            return AnyView(CarryPositionDemoView(node: node))
        case .motionIntensity:
            return AnyView(MotionIntensityDemoView(node: node))
            //        case .fitnessActivity:
            //        case .accelerationEvent:
            //        case .gnss:
            //        case .colorAmbientLight:
            //        case .tofMultiObject:
            //        case .proximity:
            //        case .qvar:
            //            return AnyView(LegacyView())
        case .textual:
            return AnyView(TextualMonitorDemoView(node: node))
        case .cloudAzureIotCentral:
            return AnyView(LegacyView())
        case .cloudMqtt:
            return AnyView(CloudMQTTConfigurationView(node: node))
        case .battery:
            return AnyView(BatteryDemoView(node: node))
        case .coSensor:
            return AnyView(LegacyView())
        case .sdLogging:
            return AnyView(LegacyView())
        case .aiLogging:
            return AnyView(LegacyView())
        case .assetTrackingEvent:
            return AnyView(AssetTrackingEventView(node: node))
        case .activityRecognition:
            return AnyView(ActivityRecognitionDemoView(node: node))
        case .speechToText:
            return AnyView(LegacyView())
            //        case .rawPnPLControlled:
            //        case .smartMotorControl:
            //        case .medicalSignal:
            //        case .binaryContent:
            //        case .wbsOtaFuota:
            //            return FirmwareSelectPresenter(param: DemoParam<FirmwareSelect>(node: node, param: nil))
        case .robotics:
            return AnyView(
                DedicatedAppView(
                    dedicatedAppInfo: DedicatedAppInfo(
                        name: "ST Robotics",
                        shortDescription: "Application for scanning and controlling robotics kits",
                        imageName: "strobotics",
                        description: "The ST Robotics Application for Android enables users to configure and operate various robotic kits and boards, such as the Robotics Evaluation Kit. This application facilitates the discovery, connection, and control of these robotic kits.",
                        url: "https://apps.apple.com/us/app/st-robotics/id6739212512"
                    )
                )
            )
        default:
            return nil
        }
    }
    
    var automaticNotification: Bool {
        switch self {
        case .plot, .textual, .machineLearningCore, .finiteStateMachine, .stredl:
            false
        default:
            true
        }
    }
}
