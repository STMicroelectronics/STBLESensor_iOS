//
//  HSDDeviceStatus.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 25/01/21.
//

import Foundation

public struct HSDDeviceStatus: Codable {
    public let type: String?
    public let isLogging: Bool?
    public let isSDInserted: Bool?
    public let cpuUsage: Double?
    public let batteryVoltage: Double?
    public let batteryLevel: Double?
    public let ssid: String?
    public let password: String?
    public let ip: String?
    public let sensorId: Int?
    public let sensorStatus: HSDSensor.SensorStatusDescriptor?
}
