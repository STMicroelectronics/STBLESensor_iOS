//
//  HSDSubSensor.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 22/01/21.
//

import Foundation
import UIKit

public class HSDSubSensor: Codable {
    public enum SensorType: String, Codable {
        case Accelerometer = "ACC"
        case Magnetometer = "MAG"
        case Gyroscope = "GYRO"
        case Temperature = "TEMP"
        case Humidity = "HUM"
        case Pressure = "PRESS"
        case Microphone = "MIC"
        case MLC = "MLC"
        case Unknown = ""
    }
    
    public let id: Int
    public let sensorType: String
    public let dimensions: Int
    public let dimensionsLabel: [String]
    public let unit: String?
    public let dataType: String?
    public let FS: [Double]?
    public let ODR: [Double]?
    public let samplesPerTs: HSDSamplesPerTs
    
    public var type: SensorType {
        SensorType(rawValue: sensorType) ?? .Unknown
    }
}
