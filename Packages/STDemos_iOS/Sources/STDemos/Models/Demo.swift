//
//  Demo.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI
import STCore

public enum Demo: String, CaseIterable, Codable {
    case flow
    case beamforming
    case environmental
    case level
    case fitnessActivity
    case compass
    case highSpeedDataLog2
    case blueVoice
    case gestureNavigation
    case neaiAnomalyDetection
    case neaiClassification
    case neaiExtrapolation
    case eventCounter
    case piano
    case pnpLike
    case plot
    case jsonNfc
    case binaryContent
    case extendedConfiguration
    case tofMultiObject
    case colorAmbientLight
    case gnss
//    case qvar
    case motionIntensity
    case activityRecognition
    case carryPosition
    case memsGesture
    case motionAlgorithm
    case pedometer
    case proximity
    case switchDemo
    case finiteStateMachine
    case machineLearningCore
    case stredl
    case accelerationEvent
    case audioSourceLocalization
    case audioClassification
    case ledControl
    case battery
    case textual
    case heartRate
    case memsSensorFusion
    case predictiveMaintenance
    case fft
    case multiNN
    case highSpeedDataLog
    case sdLogging
    case coSensor
    case aiLogging
    case assetTrackingEvent
    case speechToText
    case rawPnPLControlled
    case smartMotorControl
    case cloudAzureIotCentral
    case cloudMqtt
    case medicalSignal
    case wbsOtaFuota
}

private var pnplDemoTitle: String = "PnpLike"

public extension Demo {
    static var titles: [Demo: String] = [
        .environmental: "Environmental",
        .plot: "Plot Data",
        .fft: "FFT",
        .neaiAnomalyDetection: "NEAI Anomaly Detection",
        .neaiClassification: "NEAI Classification",
        .neaiExtrapolation: "NEAI Extrapolation",
        .predictiveMaintenance: "Predictive Maintenance",
        .highSpeedDataLog: "HighSpeed DataLog",
        .highSpeedDataLog2: "HighSpeed DataLog2",
        .pnpLike: "PnpLike",
        .extendedConfiguration: "Board Configuration",
        .switchDemo: "Switch",
        .ledControl: "Led Control",
        .heartRate: "Heart Rate",
        .blueVoice: "Blue Voice",
        .beamforming: "BeamForming",
        .audioSourceLocalization: "Audio Source Localization",
        .speechToText: "Speech to Text",
        .audioClassification: "Audio Classification",
        .activityRecognition: "Activity Recognition",
        .multiNN: "Multi Neural Network",
        .machineLearningCore: "Machine Learning Core",
        .finiteStateMachine: "Finite State Machine",
        .stredl: "STREDL",
        .flow: "Flow",
        .eventCounter: "Event Counter",
        .gestureNavigation: "Gesture Navigation",
        .jsonNfc: "JSON NFC Writing",
        .piano: "Piano",
        .pedometer: "Pedometer",
        .level: "Level",
        .compass: "Compass",
        .memsSensorFusion: "MEMS Sensor Fusion",
        .memsGesture: "Mems Gesture",
        .motionAlgorithm: "Motion Algorithm",
        .carryPosition: "Carry Position",
        .motionIntensity: "Motion Intensity",
        .fitnessActivity: "Fitness Activity",
        .accelerationEvent: "Acceleration Event",
        .gnss: "GNSS",
        .colorAmbientLight: "Color Ambient Light",
        .tofMultiObject: "ToF Multi Object",
        .proximity: "Proximity Gesture",
//        .qvar: "Electric Charge Variation",
        .textual: "Textual Monitor",
        .cloudAzureIotCentral: "Cloud Azure IoT Central",
        .cloudMqtt: "Cloud MQTT",
        .battery: "Battery",
        .coSensor: "CO Sensor",
        .sdLogging: "SD Logging",
        .aiLogging: "AI Logging",
        .assetTrackingEvent: "Asset Tracking Event",
        .rawPnPLControlled: "Raw PnPL Controlled",
        .smartMotorControl: "Smart Motor Control",
        .medicalSignal: "Medical Signals",
        .binaryContent: "Binary Content",
        .wbsOtaFuota: "FUOTA"
    ]

    var title: String {
        return Demo.titles[self] ?? "Unknown"
    }

    mutating func setTitle(_ newTitle: String) {
        Demo.titles[self] = newTitle
    }
    
    var description: String {
        switch self {
        case .environmental:
            return "Display available temperature, pressure, humidity and Lux sensors values"
        case .plot:
            return "Display the sensors' value on a configurable plot"
        case .fft:
            return "Display in a graphical way the FFT Amplitude values received from the board"
        case .neaiAnomalyDetection:
            return "AI library (generated using NanoEdgeAIStudio) for predictive maintenance solution"
        case .neaiClassification:
            return "AI library (generated using NanoEdgeAIStudio) for classification"
        case .neaiExtrapolation:
            return "AI library (generated using NanoEdgeAIStudio) for extrapolation"
        case .predictiveMaintenance:
            return "Display sensor data values acquired and processed with dedicated predictive maintenance algorithm"
        case .highSpeedDataLog:
            return "High speed sensors data log configuration, control and tagging"
        case .highSpeedDataLog2:
            return "High speed sensors data log configuration, control and tagging"
        case .pnpLike:
            return "Board Control and Configuration using PnP-Like messages defined by a DTDL-Model"
        case .extendedConfiguration:
            return "Advance board extended configuration trough json-like messages"
        case .switchDemo:
            return "Switch on/off the LED placed on the board"
        case .ledControl:
            return "Switch on/off the LED placed on the board and display RSSI value and the alarm received from the board"
        case .heartRate:
            return "Display the Heart Rate Bluetooth standard profile"
        case .blueVoice:
            return "\'Bluevoice\' ADPCM audio bluetooth streaming"
        case .beamforming:
            return "Combine signals from multiple omnidirectional microphones to synthesize a virtual microphone that captures sound from a specific direction"
        case .audioSourceLocalization:
            return "Real time source localization algorithm using the signals acquired from multiple board's microphones"
        case .speechToText:
            return "Speech to Text conversion from \"Bluevoice\" audio bluetooth streaming"
        case .audioClassification:
            return "Real time audio scene classification using the signal acquired from board's microphone"
        case .activityRecognition:
            return "Display the activity recognized using different algorithms that could be enabled on the board"
        case .multiNN:
            return "Display advanced applications such as human activity recognition or acoustic scene classification on the basis of output generated by multi neural networks"
        case .machineLearningCore:
            return "Display the registers output for the Machine Learning core present on advance accelerometer"
        case .finiteStateMachine:
            return "Display the registers output for the Finite State Machine core present on advance accelerometer"
        case .stredl:
            return "Display the registers output for the STRed-ISPU core"
        case .flow:
            return "Create a new application"
        case .eventCounter:
            return "Display the counter that will be increased at each event detected by board"
        case .gestureNavigation:
            return "Recognition of gesture navigation using sensor"
        case .jsonNfc:
            return "Write NDEF records (Text/Wi-Fi/Business Card and URL) to the board"
        case .binaryContent:
            return "Receive or Send to the board a Binary content"
        case .piano:
            return "Display a Piano keyboard for playing audio notes on the board"
        case .pedometer:
            return "Calculate number of steps and its frequency"
        case .level:
            return "Show Level and Pitch&Roll"
        case .compass:
            return "Display a magnetic compass direction"
        case .memsSensorFusion:
            return "6-axis or 9-axis Sensor Fusion demo"
        case .memsGesture:
            return "Recognition of the gesture performed by the user with the board"
        case .motionAlgorithm:
            return "Recognition of different human stances with different algorithms"
        case .carryPosition:
            return "Display the board carry position recognized"
        case .motionIntensity:
            return "Display the level of motion intensity measured by the board"
        case .fitnessActivity:
            return "Display recognized fitness activity and counter reps"
        case .accelerationEvent:
            return "Detect different acceleration event types"
        case .gnss:
            return "Display GNSS coordinates (Latitude, Longitude and Altitude) and satellites' signal information"
        case .colorAmbientLight:
            return "Display illuminance, intensity UV radiation and correlated color temperature"
        case .tofMultiObject:
            return "Multi objects' distance and presence detection using Time-of-Flight (ToF) sensor"
        case .proximity:
            return "Gesture recognition (tap/swap) using Time-of-Flight (ToF) sensor"
//        case .qvar:
//            return "Display Raw data coming from electric charge variation (QVAR) sensor"
        case .textual:
            return "Show in a textual way the values received and parsed from any bluetooth characteristics"
        case .cloudAzureIotCentral:
            return "Connect the board to one Azure IoT Central Dashboard"
        case .cloudMqtt:
            return "Connect the board to one MQTT Server"
        case .battery:
            return "Display board RSSI and Battery information if available"
        case .coSensor:
            return "Display electrochemical toxic gas level though CO Sensor"
        case .sdLogging:
            return "Configure and control a simple sensors data log"
        case .aiLogging:
            return "Configure, control and tag a simple sensors data log"
        case .assetTrackingEvent:
            return "Show asset tracking detected events, such as Fall or Shock Events"
        case .rawPnPLControlled:
            return "Raw Feature controlled using PnP-Like messages defined by a DTDL-Model"
        case .medicalSignal:
            return "Display Medical Signals"
        case .smartMotorControl:
            return "Motor Control Integration with high speed sensors data log configuration, control and tagging"
        case .wbsOtaFuota:
            return "Firmware Update Over the Air for WB/WBA boards"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .environmental:
            return ImageLayout.image(with: "demo_environmental", in: STUI.bundle)
        case .plot:
            return ImageLayout.image(with: "demo_charts", in: STUI.bundle)
        case .fft:
            return ImageLayout.image(with: "demo_charts", in: STUI.bundle)
        case .neaiAnomalyDetection:
            return ImageLayout.image(with: "demo_neai", in: STUI.bundle)
        case .neaiClassification:
            return ImageLayout.image(with: "demo_neai", in: STUI.bundle)
        case .neaiExtrapolation:
            return ImageLayout.image(with: "demo_neai", in: STUI.bundle)
        case .predictiveMaintenance:
            return ImageLayout.image(with: "demo_predictive", in: STUI.bundle)
        case .highSpeedDataLog:
            return ImageLayout.image(with: "demo_hsdatalog", in: STUI.bundle)
        case .highSpeedDataLog2:
            return ImageLayout.image(with: "demo_hsdatalog", in: STUI.bundle)
        case .pnpLike:
            return ImageLayout.image(with: "demo_pnpl", in: STUI.bundle)
        case .extendedConfiguration:
            return ImageLayout.image(with: "demo_ext_config", in: STUI.bundle)
        case .switchDemo:
            return ImageLayout.image(with: "demo_switch", in: STUI.bundle)
        case .ledControl:
            return ImageLayout.image(with: "demo_ambient_light", in: STUI.bundle)
        case .heartRate:
            return ImageLayout.image(with: "demo_heart_rate", in: STUI.bundle)
        case .blueVoice:
            return ImageLayout.image(with: "demo_bluevoice", in: STUI.bundle)
        case .beamforming:
            return ImageLayout.image(with: "demo_beamforming", in: STUI.bundle)
        case .audioSourceLocalization:
            return ImageLayout.image(with: "demo_source_localization", in: STUI.bundle)
        case .speechToText:
            return ImageLayout.image(with: "demo_bluevoice", in: STUI.bundle)
        case .audioClassification:
            return ImageLayout.image(with: "demo_bluevoice", in: STUI.bundle)
        case .activityRecognition:
            return ImageLayout.image(with: "demo_activity", in: STUI.bundle)
        case .multiNN:
            return ImageLayout.image(with: "demo_nn", in: STUI.bundle)
        case .machineLearningCore:
            return ImageLayout.image(with: "demo_nn", in: STUI.bundle)
        case .finiteStateMachine:
            return ImageLayout.image(with: "demo_nn", in: STUI.bundle)
        case .stredl:
            return ImageLayout.image(with: "demo_nn", in: STUI.bundle)
        case .flow:
            return ImageLayout.image(with: "demo_flow", in: STUI.bundle)
        case .eventCounter:
            return ImageLayout.image(with: "demo_event_counter", in: STUI.bundle)
        case .gestureNavigation:
            return ImageLayout.image(with: "demo_gesture_navigation", in: STUI.bundle)
        case .jsonNfc:
            return ImageLayout.image(with: "demo_nfc", in: STUI.bundle)
        case .piano:
            return ImageLayout.image(with: "demo_piano", in: STUI.bundle)
        case .pedometer:
            return ImageLayout.image(with: "demo_pedometer", in: STUI.bundle)
        case .level:
            return ImageLayout.image(with: "demo_level", in: STUI.bundle)
        case .compass:
            return ImageLayout.image(with: "demo_compass", in: STUI.bundle)
        case .memsSensorFusion:
            return ImageLayout.image(with: "demo_sensor_fusion", in: STUI.bundle)
        case .memsGesture:
            return ImageLayout.image(with: "demo_proximity", in: STUI.bundle)
        case .motionAlgorithm:
            return ImageLayout.image(with: "demo_activity", in: STUI.bundle)
        case .carryPosition:
            return ImageLayout.image(with: "demo_carry", in: STUI.bundle)
        case .motionIntensity:
            return ImageLayout.image(with: "demo_activity", in: STUI.bundle)
        case .fitnessActivity:
            return ImageLayout.image(with: "demo_fitness", in: STUI.bundle)
        case .accelerationEvent:
            return ImageLayout.image(with: "demo_acceleration_event", in: STUI.bundle)
        case .gnss:
            return ImageLayout.image(with: "demo_gnss", in: STUI.bundle)
        case .colorAmbientLight:
            return ImageLayout.image(with: "demo_ambient_light", in: STUI.bundle)
        case .tofMultiObject:
            return ImageLayout.image(with: "demo_tof", in: STUI.bundle)
        case .proximity:
            return ImageLayout.image(with: "demo_proximity", in: STUI.bundle)
//        case .qvar:
//            return ImageLayout.image(with: "demo_qvar", in: STUI.bundle)
        case .textual:
            return ImageLayout.image(with: "demo_textual", in: STUI.bundle)
        case .cloudAzureIotCentral:
            return ImageLayout.image(with: "demo_cloud_azure_iot_central", in: STUI.bundle)
        case .cloudMqtt:
            return ImageLayout.image(with: "demo_cloud_mqtt", in: STUI.bundle)
        case .battery:
            return ImageLayout.image(with: "demo_battery", in: STUI.bundle)
        case .coSensor:
            return ImageLayout.image(with: "demo_co_sensor", in: STUI.bundle)
        case .sdLogging:
            return ImageLayout.image(with: "demo_multiple_log", in: STUI.bundle)
        case .aiLogging:
            return ImageLayout.image(with: "demo_multiple_log", in: STUI.bundle)
        case .assetTrackingEvent:
            return ImageLayout.image(with: "demo_asset_tracking_event", in: STUI.bundle)
        case .rawPnPLControlled:
            return ImageLayout.image(with: "demo_raw_pnpl", in: STUI.bundle)
        case .medicalSignal:
            return  ImageLayout.image(with: "demo_medical_signal", in: STUI.bundle)
        case .smartMotorControl:
            return ImageLayout.image(with: "demo_smart_motor_control", in: STUI.bundle)
        case .binaryContent:
            return ImageLayout.image(with: "demo_binary_content", in: STUI.bundle)
        case .wbsOtaFuota:
            return ImageLayout.image(with: "demo_wb_fuota", in: STUI.bundle)
        }
    }
    
    var groups: [DemoGroup] {
        switch self {
        case .environmental:
            return [ .environmental ]
        case .plot:
            return [ .graphs, .log ]
        case .fft:
            return [ .predictiveMaintenance, .graphs ]
        case .neaiAnomalyDetection:
            return [ .ai, .predictiveMaintenance ]
        case .neaiClassification:
            return [ .ai ]
        case .neaiExtrapolation:
            return [.ai]
        case .predictiveMaintenance:
            return [ .predictiveMaintenance, .status ]
        case .highSpeedDataLog:
            return [ .dataLog, .ai ]
        case .highSpeedDataLog2:
            return [ .dataLog, .ai ]
        case .pnpLike:
            return [ .control, .configuration ]
        case .extendedConfiguration:
            return [ .configuration ]
        case .switchDemo:
            return [ .control ]
        case .ledControl:
            return [ .control ]
        case .heartRate:
            return [ .health ]
        case .blueVoice:
            return [ .audio ]
        case .beamforming:
            return [ .audio ]
        case .audioSourceLocalization:
            return [ .audio ]
        case .speechToText:
            return [ .audio, .cloud ]
        case .audioClassification:
            return [ .ai, .audio ]
        case .activityRecognition:
            return [ .ai, .inertialSensors, .health ]
        case .multiNN:
            return [ .ai, .audio, .inertialSensors, .health ]
        case .machineLearningCore:
            return [ .ai, .inertialSensors ]
        case .finiteStateMachine:
            return [ .ai, .inertialSensors ]
        case .stredl:
            return [ .ai, .inertialSensors ]
        case .flow:
            return [ .control ]
        case .eventCounter:
            return [ .status ]
        case .gestureNavigation:
            return [ .environmental, .control ]
        case .jsonNfc:
            return [ .configuration ]
        case .piano:
            return [ .audio ]
        case .pedometer:
            return [ .inertialSensors ]
        case .level:
            return [ .inertialSensors ]
        case .compass:
            return [ .inertialSensors ]
        case .memsSensorFusion:
            return [ .inertialSensors ]
        case .memsGesture:
            return [ .inertialSensors ]
        case .motionAlgorithm:
            return [ .inertialSensors ]
        case .carryPosition:
            return [ .inertialSensors ]
        case .motionIntensity:
            return [ .inertialSensors ]
        case .fitnessActivity:
            return [ .health, .inertialSensors ]
        case .accelerationEvent:
            return [ .inertialSensors ]
        case .gnss:
            return [ .environmental ]
        case .colorAmbientLight:
            return [ .environmental ]
        case .tofMultiObject:
            return [ .environmental ]
        case .proximity:
            return [ .environmental ]
//        case .qvar:
//            return [ .environmental ]
        case .textual:
            return [ .debug ]
        case .cloudAzureIotCentral:
            return [ .cloud ]
        case .cloudMqtt:
            return [ .cloud ]
        case .battery:
            return [ .status ]
        case .coSensor:
            return [ .environmental ]
        case .sdLogging:
            return [ .log ]
        case .aiLogging:
            return [ .log, .ai ]
        case .assetTrackingEvent:
            return [ .inertialSensors ]
        case .rawPnPLControlled:
            return [ .control ]
        case .medicalSignal:
            return [ .health, .graphs]
        case .smartMotorControl:
            return [ .control, .dataLog ]
        case .binaryContent:
            return [.binaryContent]
        case .wbsOtaFuota:
            return [ .fota ]
        }
    }
    
    var features: [Feature.Type] {
        switch self {
        case .environmental:
            return [
                TemperatureFeature.self,
                HumidityFeature.self,
                PressureFeature.self
            ]
        case .plot:
            return [
                AccelerationFeature.self,
                CompassFeature.self,
                DirectionOfArrivalFeature.self,
                GyroscopeFeature.self,
                HumidityFeature.self,
                LuminosityFeature.self,
                MagnetometerFeature.self,
                SensorFusionFeature.self,
                SensorFusionCompactFeature.self,
                MicLevelFeature.self,
                MotionIntensityFeature.self,
                ProximityFeature.self,
                PressureFeature.self,
                TemperatureFeature.self,
                COSensorFeature.self,
                EulerAngleFeature.self,
                MemsNormFeature.self,
//                QVARFeature.self,
//                ToFMultiObjectFeature.self,
                EventCounterFeature.self,
                NEAIExtrapolationFeature.self
            ]
        case .fft:
            return [ FFTAmplitudeFeature.self ] /// MotorTimeParametersFeature.self
        case .neaiAnomalyDetection:
            return [ NEAIAnomalyDetectionFeature.self ]
        case .neaiClassification:
            return [ NEAIClassificationFeature.self ]
        case .neaiExtrapolation:
            return [ NEAIExtrapolationFeature.self ]
        case .predictiveMaintenance:
            return [
                PredictiveAccelerationStatusFeature.self,
                PredictiveFrequencyDomainStatusFeature.self,
                PredictiveSpeedStatusFeature.self
            ]
        case .highSpeedDataLog:
            return [ HSDFeature.self ]
        case .highSpeedDataLog2:
            return [
                HSDFeature.self,
                PnPLFeature.self
            ]
        case .pnpLike:
            return [ PnPLFeature.self ]
        case .extendedConfiguration:
            return [ ExtendedConfigurationFeature.self ]
        case .switchDemo:
            return [ SwitchFeature.self ]
        case .ledControl:
            return [
                ControlLedFeature.self,
                STM32SwitchStatusFeature.self,
            ]
        case .heartRate:
            return [ HeartRateFeature.self ]
        case .blueVoice:
            return [
                ADPCMAudioSyncFeature.self,
                ADPCMAudioFeature.self,
                OpusAudioConfFeature.self,
                OpusAudioFeature.self,
                BeamFormingFeature.self
            ]
        case .beamforming:
            return [
                ADPCMAudioSyncFeature.self,
                ADPCMAudioFeature.self,
//                OpusAudioConfFeature.self,
                OpusAudioFeature.self,
                BeamFormingFeature.self
            ]
        case .audioSourceLocalization:
            return [ DirectionOfArrivalFeature.self ]
        case .speechToText:
            return [
                ADPCMAudioSyncFeature.self,
                ADPCMAudioFeature.self,
                OpusAudioConfFeature.self,
                OpusAudioFeature.self,
                BeamFormingFeature.self
            ]
        case .activityRecognition:
            return [ ActivityFeature.self ]
        case .audioClassification:
            return [ AudioClassificationFeature.self ]
        case .multiNN:
            return [
                ActivityFeature.self,
                AudioClassificationFeature.self
            ]
        case .machineLearningCore:
            return [ 
                MachineLearningCoreFeature.self
//                RawPnPLControlledFeature.self
            ]
        case .finiteStateMachine:
            return [ FiniteStateMachineFeature.self ]
        case .stredl:
            return [ STREDLFeature.self ]
        case .flow:
            return []
        case .eventCounter:
            return [ EventCounterFeature.self ]
        case .gestureNavigation:
            return [ GestureNavigationFeature.self ]
        case .jsonNfc:
            return [ JsonNFCFeature.self ]
        case .piano:
            return [ PianoFeature.self ]
        case .pedometer:
            return [ PedometerFeature.self ]
        case .level:
            return [ EulerAngleFeature.self ]
        case .compass:
            return [ CompassFeature.self ] /// EulerAngleFeature.self
        case .memsSensorFusion:
            return [
                SensorFusionCompactFeature.self,
                SensorFusionFeature.self
            ] /// ProximityFeature.self, AccelerationEventFeature.self,
        case .memsGesture:
            return [ MemsGestureFeature.self ]
        case .motionAlgorithm:
            return [ MotionAlgorithmFeature.self ]
        case .carryPosition:
            return [ CarryPositionFeature.self ]
        case .motionIntensity:
            return [ MotionIntensityFeature.self ]
        case .fitnessActivity:
            return [ FitnessActivityFeature.self ]
        case .accelerationEvent:
            return [ AccelerationEventFeature.self ]
        case .gnss:
            return [ GNSSFeature.self ]
        case .colorAmbientLight:
            return [ ColorAmbientLightFeature.self ]
        case .tofMultiObject:
            return [ ToFMultiObjectFeature.self ]
        case .proximity:
            return [ ProximityGestureFeature.self ]
//        case .qvar:
//            return [ QVarFeature.self ]
        case .textual:
            return []
        case .cloudAzureIotCentral, .cloudMqtt:
            return []
        case .battery:
            return [ BatteryFeature.self ]
        case .rawPnPLControlled:
            return [
                PnPLFeature.self,
                RawPnPLControlledFeature.self
            ]
        case .smartMotorControl:
            return [
                RawPnPLControlledFeature.self,
                PnPLFeature.self
            ]
        case .wbsOtaFuota:
            return []
//        case .cloudAzureIoTCentral:
//            return []
        case .binaryContent:
            return [
                BinaryContentFeature.self,
                PnPLFeature.self
            ]
        case .sdLogging:
            return [ SDLoggingFeature.self ]
        case .coSensor:
            return [ COSensorFeature.self ]
        case .aiLogging:
            return [ AILoggingFeature.self ]
        case .assetTrackingEvent:
            return [ AssetTrackingEventFeature.self ]
        case .medicalSignal:
            return [ MedicalSignal16BitFeature.self,
                     MedicalSignal24BitFeature.self]
        }
    }
    
    var allFeaturesMandatory: Bool {
        switch self {
        case .highSpeedDataLog2, .blueVoice, .extendedConfiguration, .ledControl, .multiNN, .beamforming, .rawPnPLControlled, .smartMotorControl, .binaryContent:
            return true
        default:
            return false
        }
    }
    
    var couldBeEnableOutside: Bool {
        switch self {
        case .cloudAzureIotCentral, .cloudMqtt, .flow, .textual, .wbsOtaFuota:
            return true
        default:
            return false
        }
    }
    
    func presenter(with node: Node, param: Any? = nil) -> Presenter {
        switch self {
        case .environmental:
            return EnviromentalPresenter(param: DemoParam<Void>(node: node))
        case .plot:
            return PlotPresenter(param: DemoParam<Void>(node:node))
        case .fft:
            return FFTPresenter(param: DemoParam<Void>(node: node))
        case .neaiAnomalyDetection:
            return NEAIAnomalyDetectionPresenter(param: DemoParam<Void>(node: node))
        case .neaiClassification:
            return NEAIClassificationPresenter(param: DemoParam<Void>(node: node))
        case .neaiExtrapolation:
            return NEAIExtrapolationPresenter(param: DemoParam<Void>(node: node))
        case .predictiveMaintenance:
            return PredictiveMaintenancePresenter(param: DemoParam<Void>(node: node))
        case .highSpeedDataLog:
            return LegacyPresenter(param: DemoParam<String>(node: node, param: "High Speed Datalog"))
        case .highSpeedDataLog2:
            return HSDPresenter(param: DemoParam<Void>(node: node, showTabBar: true))
        case .pnpLike:
            guard let param = param as? PnplDemoConfiguration else {
                return PnpLPresenter(param: DemoParam<[PnpLContent]>(node: node, param: nil))
            }
            return PnpLPresenter(type: param.type, param: DemoParam<[PnpLContent]>(node: node, param: param.contents))
        case .extendedConfiguration:
            return ExtendedConfigurationPresenter(param: DemoParam<Void>(node: node))
        case .switchDemo:
            return SwitchPresenter(param: DemoParam<Void>(node: node))
        case .ledControl:
            return STM32WBLedButtonControlPresenter(rssi: param as? Int ?? 0, param: DemoParam<Void>(node: node))
        case .heartRate:
            return HeartRatePresenter(param: DemoParam<Void>(node:node))
        case .blueVoice:
            return BlueVoicePresenter(param: DemoParam<Void>(node: node))
        case .beamforming:
            return BeamFormingPresenter(param: DemoParam<Void>(node: node))
        case .audioSourceLocalization:
            return AudioSourceLocalizationPresenter(param: DemoParam<Void>(node: node))
        case .audioClassification:
            return AudioClassificationPresenter(param: DemoParam<Void>(node: node))
        case .activityRecognition:
            return ActivityRecognitionPresenter(param: DemoParam<Void>(node: node))
        case .multiNN:
            return MultiNeuralNetworkPresenter(param: DemoParam<Void>(node:node))
        case .machineLearningCore:
            return MachineLearningCorePresenter(param: DemoParam<String>(node: node, param: nil))
        case .finiteStateMachine:
            return FiniteStateMachinePresenter(param: DemoParam<Void>(node: node))
        case .stredl:
            return STREDLPresenter(param: DemoParam<Void>(node: node))
        case .flow:
            return FlowMainPresenter(param: DemoParam<Void>(node: node, showTabBar: true))
        case .eventCounter:
            return EventCounterPresenter(param: DemoParam<Void>(node: node))
        case .gestureNavigation:
            return GestureNavigationPresenter(param: DemoParam<Void>(node: node))
        case .jsonNfc:
            return JsonNfcPresenter(param: DemoParam<Void>(node: node))
        case .piano:
           return PianoPresenter(param: DemoParam<Void>(node: node))
        case .pedometer:
            return PedometerPresenter(param: DemoParam<Void>(node: node))
        case .level:
            return LevelPresenter(param: DemoParam<Void>(node: node))
        case .compass:
            return CompassPresenter(param: DemoParam<Void>(node: node))
        case .memsSensorFusion:
            return MEMSSensorFusionPresenter(param: DemoParam<Void>(node: node))
        case .memsGesture:
            return MemsGesturePresenter(param: DemoParam<Void>(node: node))
        case .motionAlgorithm:
            return MotionAlgorithmsPresenter(param: DemoParam<Void>(node: node))
        case .carryPosition:
            return CarryPositionPresenter(param: DemoParam<Void>(node: node))
        case .motionIntensity:
            return MotionIntensityPresenter(param: DemoParam<Void>(node: node))
        case .fitnessActivity:
            return FitnessActivityPresenter(param: DemoParam<Void>(node: node))
        case .accelerationEvent:
            return AccelerationEventPresenter(param: DemoParam<Void>(node: node))
        case .gnss:
            return GNSSPresenter(param: DemoParam<Void>(node: node))
        case .colorAmbientLight:
            return ColorAmbientLightPresenter(param: DemoParam<Void>(node: node))
        case .tofMultiObject:
            return ToFMultiObjectPresenter(param: DemoParam<Void>(node: node))
        case .proximity:
            return ProximityGesturePresenter(param: DemoParam<Void>(node: node))
//        case .qvar:
//            return LegacyPresenter(param: DemoParam<String>(node: node, param: "Electric Charge Variation"))
        case .textual:
            return TextualMonitorPresenter(param: DemoParam<Void>(node:node))
        case .cloudAzureIotCentral:
            return LegacyPresenter(param: DemoParam<String>(node: node, param: "Cloud Azure IoT Central"))
        case .cloudMqtt:
//            return LegacyPresenter(param: DemoParam<String>(node: node, param: "Cloud MQTT"))
            return CloudMQTTPresenter(param: DemoParam<Void>(node: node))
        case .battery:
            return BatteryPresenter(rssi: param as? Int ?? 0, param: DemoParam<Void>(node: node))
        case .coSensor:
            return LegacyPresenter(param: DemoParam<String>(node: node, param: "CO Sensor"))
        case .sdLogging:
            return LegacyPresenter(param: DemoParam<String>(node: node, param: "SD Logging"))
        case .aiLogging:
            return LegacyPresenter(param: DemoParam<String>(node: node, param: "AI Logging"))
        case .assetTrackingEvent:
            return AssetTrackingEventPresenter(param: DemoParam<Void>(node: node, showTabBar: false))
        case .speechToText:
            return LegacyPresenter(param: DemoParam<String>(node: node, param: "Speech To Text"))
        case .rawPnPLControlled:
            return RawPnPLControlledPresenter(param: DemoParam<Void>(node: node))
        case .smartMotorControl:
            return SmartMotorControlPresenter(param: DemoParam<Void>(node: node, showTabBar: true))
        case .medicalSignal:
            return MedicalSignalPresenter(param: DemoParam<Void>(node: node))
        case .binaryContent:
            return  BinaryContentPresent(param: DemoParam<Void>(node: node))
        case .wbsOtaFuota:
            return FirmwareSelectPresenter(param: DemoParam<FirmwareSelect>(node: node, param: nil))
        }
    }
    
    static func demos(with features: [Feature], node: Node, completion: @escaping(([Demo]) -> (Void))) {
        if node.protocolVersion == UInt8(2) {
            if let catalogService: CatalogService = Resolver.shared.resolve(),
               let catalog = catalogService.catalog,
               let firmware = catalog.v2Firmware(with: node.deviceId.longHex, firmwareId: UInt32(node.bleFirmwareVersion).longHex) {
                BlueManager.shared.updateDtmi(with: .prod, firmware: firmware) { dtmiElements, error in
                    if !dtmiElements.isEmpty && error == nil {
                        let dtmi = FirmwareDtmi(firmware: firmware, contents: dtmiElements)
                        completion(evaluateAvailableDemos(with: features, node: node, firmware: firmware, dtmi: dtmi))
                    } else {
                        BlueManager.shared.updateDtmi(with: .dev, firmware: firmware) { dtmiElements, error in
                            if !dtmiElements.isEmpty && error == nil {
                                let dtmi = FirmwareDtmi(firmware: firmware, contents: dtmiElements)
                                completion(evaluateAvailableDemos(with: features, node: node, firmware: firmware, dtmi: dtmi))
                            } else {
                                completion(evaluateAvailableDemos(with: features, node: node, firmware: firmware, dtmi: nil))
                            }
                        }
                    }
                }
            } else {
                completion(evaluateAvailableDemos(with: features, node: node, firmware: nil, dtmi: nil))
            }
        } else {
            completion(evaluateAvailableDemos(with: features, node: node, firmware: nil, dtmi: nil))
        }
    }
    
    static func demos(withFeatureTypes featureTypes: [Feature.Type]) -> [Demo] {
        
        var demos = [Demo]()
        
        for demo in Demo.allCases {
            
            var isDemoAvailable = false
            
            if demo.allFeaturesMandatory {
                isDemoAvailable = demo.features.allSatisfy { feature in
                    featureTypes.contains(where: { $0 == feature})
                }
            } else {
                for featureType in featureTypes {
                    if demo.features.contains(where: { $0 == featureType }) {
                        isDemoAvailable = true
                        break
                    }
                }
            }
            
            if isDemoAvailable {
                demos.append(demo)
            }
        }
        
        if demos.contains(where: { $0 == Demo.highSpeedDataLog2} ) {
            if let  index = demos.firstIndex(of: Demo.highSpeedDataLog) {
                demos.remove(at: index)
            }
        }
        
        return demos
    }
    
    private static func evaluateAvailableDemos(with features: [Feature], node: Node, firmware: Firmware?, dtmi: FirmwareDtmi?) -> [Demo] {
        var demos = [Demo]()
        let featureTypes = features.map { type(of: $0) }
        
        for demo in Demo.allCases {
            
            var isDemoAvailable = false
            
            if demo.couldBeEnableOutside {
                
                if demo == .wbsOtaFuota {
                    if node.type.family == .wbFamily || node.type == .nucleoWB0X || node.type == .wba65RiNucleoBoard || node.type.family == .wbaFamily {
                        isDemoAvailable = true
                    }
                } 
                else if demo == .flow {
                    if let dtmi = dtmi,
                       let demoDecorator = dtmi.firmware.demoDecorator {
                        if demoDecorator.add.contains(self.flow.title) {
                            isDemoAvailable = true
                        }
                    }
                } else if demo == .cloudAzureIotCentral {
                    if (firmware?.cloudApps?.first(where: { $0.dtmiType == "iotc"})) != nil {
                        isDemoAvailable = true
                    }
                } else if (demo == .textual) || (demo == .cloudMqtt) {
                    let filteredFeatures = features.filter{$0.isDataNotifyFeature}
                    if(!filteredFeatures.isEmpty) {
                        isDemoAvailable = true
                    }
                } else {
                    isDemoAvailable = true
                }
            } else {
                if demo.allFeaturesMandatory {
                    isDemoAvailable = demo.features.allSatisfy { feature in
                        featureTypes.contains(where: { $0 == feature})
                    }
                } else {
                    for featureType in featureTypes {
                        if demo.features.contains(where: { $0 == featureType }) {
                            isDemoAvailable = true
                            break
                        }
                    }
                }
            }
            
            if isDemoAvailable {
                demos.append(demo)
            }
        }
        
        let hsd2Set = Set([highSpeedDataLog, pnpLike])
        let demosSet = Set(demos)
        let isHSD2found = hsd2Set.isSubset(of: demosSet)
        
        if isHSD2found == true {
            demos.removeAll(where: { $0 == highSpeedDataLog } )
        }
        
        let pnplSet = Set([pnpLike])
        let newDemosSet = Set(demos)
        let isPnPLfound = pnplSet.isSubset(of: newDemosSet)
        
        if isPnPLfound,
           let firmware = firmware {
            if let demoIndex = demos.firstIndex(where: { $0 == .pnpLike }) {
                demos[demoIndex].setTitle(firmware.name)
            }
        }
        
        if let dtmi = dtmi,
           let demoDecorator = dtmi.firmware.demoDecorator {
            demoDecorator.rename.forEach { demoToRename in
                if let demoIndex = demos.firstIndex(where: { $0.title == demoToRename.old }) {
                    demos[demoIndex].setTitle(demoToRename.new)
                }
            }
            demoDecorator.add.forEach { demoToAdd in
                if demoToAdd != Demo.flow.title {
                    if let demoToAppend = Demo.allCases.first(where: { $0.title == demoToAdd }) {
                        demos.append(demoToAppend)
                    }
                }
            }
            if !UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
                demoDecorator.remove.forEach { demoName in
                    demos.removeAll(where: {$0.title == demoName })
                }
            }
        }
        
        return demos
    }
}

public enum DemoGroup: String, CaseIterable {
    case control = "Control"
    case binaryContent = "Binary Content"
    case environmental = "Environmental Sensors"
    case configuration = "Configuration"
    case ai = "AI"
    case inertialSensors = "InertialSensors"
    case debug = "Debug"
    case health = "Health"
    case log = "Log"
    case dataLog = "DataLog"
    case audio = "Audio"
    case cloud = "Cloud"
    case predictiveMaintenance = "Predictive Maintenance"
    case graphs = "Graphs"
    case status = "Status"
    case fota = "FOTA"
}

public struct PnplDemoConfiguration {
    public var type: PNPLDemoType
    public var contents: [PnpLContent]?
    
    public init(type: PNPLDemoType = .standard, contents: [PnpLContent]? = nil) {
        self.type = type
        self.contents = contents
    }
}
