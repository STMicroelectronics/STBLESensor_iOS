//
//  HSDDevice.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 22/01/21.
//

import Foundation

public class HSDDevice: Codable {
    public let deviceInfo: HSDDeviceInfo
    public var sensor: [HSDSensor]
    public var tagConfig: HSDTagConfig
    
    public func sensorWithId(_ id: Int) -> HSDSensor? {
        sensor.first(where: { $0.id == id })
    }
}
