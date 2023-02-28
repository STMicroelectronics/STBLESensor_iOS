//
//  PnPLConfiguration.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation


// MARK: - PnPLConfiguration
public struct PnPLConfiguration {
    public let name: String
    public let specificSensorOrGeneralType: PnPLType
    public let displayName: String?
    public var parameters: [PnPLConfigurationParameter]?
    public var visibile: Bool

}

// MARK: - PnPLConfigurationParameters
public struct PnPLConfigurationParameter {
    public let name: String?
    public let displayName: String?
    public let type: ParameterType?
    public var detail: ParameterDetail?
    public let unit: String?
    public let writable: Bool?
}

public struct ParameterDetail {
    public let requestName: String?
    public let primitiveType: String?
    public var currentValue: Any?
    public let enumValues: [Int: String]?
    public var paramObj: [ObjectNameValue]?
}

public struct ObjectNameValue {
    public let primitiveType: String?
    public let name: String?
    public let displayName: String?
    public var currentValue: Any?
}

public enum ParameterType {
    case PropertyStandard
    case PropertyEnumeration
    case PropertyObject
    case CommandEmpty
    case CommandStandard
    case CommandEnumeration
    case CommandObject
}


// MARK: - PnPLType
public enum PnPLType: String, Codable {
    case Accelerometer = "acc"
    case Magnetometer = "mag"
    case Gyroscope = "gyro"
    case Temperature = "temp"
    case Humidity = "hum"
    case Pressure = "press"
    case Microphone = "mic"
    case MLC = "mlc"
    case Unknown = ""
}

public extension PnPLType {
    public var icon: UIImage? {
        switch self {
            case .Accelerometer:
                return UIImage(named: "ic_accelerometer")
            case .Magnetometer:
                return UIImage(named: "ic_magnetometer")
            case .Gyroscope:
                return UIImage(named: "ic_gyroscope")
            case .Temperature:
                return UIImage(named: "ic_termometer")
            case .Humidity:
                return UIImage(named: "ic_humidity")
            case .Pressure:
                return UIImage(named: "ic_pressure")
            case .Microphone:
                return UIImage(named: "ic_microphone")
            case .MLC:
                return UIImage(named: "ic_mlc")
            case .Unknown:
                return UIImage(named: "ic_info")
                
        }
    }
    
    public var name: String? {
        switch self {
            case .Accelerometer:
                return "Accelerometer"
            case .Magnetometer:
                return "Magnetometer"
            case .Gyroscope:
                return "Gyroscope"
            case .Temperature:
                return "Temperature"
            case .Humidity:
                return "Humidity"
            case .Pressure:
                return "Pressure"
            case .Microphone:
                return "Microphone"
            case .MLC:
                return "MLC"
            case .Unknown:
                return nil
        }
    }
}
