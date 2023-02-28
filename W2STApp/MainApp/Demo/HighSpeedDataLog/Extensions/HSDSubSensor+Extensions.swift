//
//  HSDSubSensor+Extensions.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK_Gui

public extension HSDSubSensor.SensorType {
    var icon: UIImage? {
        switch self {
            case .Accelerometer:
                return UIImage.namedFromGUI("ic_accelerometer")
            case .Magnetometer:
                return UIImage.namedFromGUI("ic_magnetometer")
            case .Gyroscope:
                return UIImage.namedFromGUI("ic_gyroscope")
            case .Temperature:
                return UIImage.namedFromGUI("ic_temperature")
            case .Humidity:
                return UIImage.namedFromGUI("ic_humidity")
            case .Pressure:
                return UIImage.namedFromGUI("ic_pressure")
            case .Microphone:
                return UIImage.namedFromGUI("ic_microphone")
            case .MLC:
                return UIImage.namedFromGUI("ic_mlc")
            case .Unknown:
                return UIImage.namedFromGUI("sensor_type_unknown")
        }
    }
    
    var name: String {
        switch self {
            case .Accelerometer:
                return "sensor.accelerometer.title".localizedFromGUI
            case .Magnetometer:
                return "sensor.magnetometer.title".localizedFromGUI
            case .Gyroscope:
                return "sensor._gyroscope.title".localizedFromGUI
            case .Temperature:
                return "sensor.termometer.title".localizedFromGUI
            case .Humidity:
                return "sensor.humidity.title".localizedFromGUI
            case .Pressure:
                return "sensor.pressure.title".localizedFromGUI
            case .Microphone:
                return "sensor.microphone.title".localizedFromGUI
            case .MLC:
                return "sensor.mlc".localizedFromGUI
            case .Unknown:
                return "sensor_type_unknown.title".localizedFromGUI
        }
    }
}
