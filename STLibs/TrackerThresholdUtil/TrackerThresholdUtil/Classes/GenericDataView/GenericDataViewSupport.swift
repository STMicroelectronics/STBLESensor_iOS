//
//  GenericDataViewSupport.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public let iso8601FormatterTag2Samples: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: Locale.current.identifier)
    formatter.dateFormat = "HH:mm:ss - dd/MM"
    return formatter
}()

public func setSensorImage(type: String) -> UIImage? {
    switch type {
    case "battery_percentage":
        return TrackerThresholdUtilBundle.bundleImage(named: "battery_sensor_percent")
    case "battery_voltage":
        return TrackerThresholdUtilBundle.bundleImage(named: "battery_sensor_voltage")
    case "tem":
        return TrackerThresholdUtilBundle.bundleImage(named: "temperature_icon")
    case "pre":
        return TrackerThresholdUtilBundle.bundleImage(named: "pressure_icon")
    case "hum":
        return TrackerThresholdUtilBundle.bundleImage(named: "humidity_icon")
    case "imu_acc":
        return TrackerThresholdUtilBundle.bundleImage(named: "event_wakeUp")
    case "6d_acc":
        return TrackerThresholdUtilBundle.bundleImage(named: "event_orientation")
    case "tilt_acc":
        return TrackerThresholdUtilBundle.bundleImage(named: "event_tilt")
    case "acc/gyro":
        return TrackerThresholdUtilBundle.bundleImage(named: "acc_gyro_sensor")
    default:
        return TrackerThresholdUtilBundle.bundleImage(named: "generic_sensor")
    }
}
