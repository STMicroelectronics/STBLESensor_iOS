//
//  BlueSTSDKFeatureHighSpeedDataLog.swift
//  W2STApp
//
//  Created by Dimitri Giani on 18/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

@objc
public class BlueSTSDKFeatureHighSpeedDataLog : BlueSTSDKFeature {
    private static let FEATURE_NAME = "HSDataLogConfig"
    private static let FEATURE_DATA_NAME = "ConfigJson"
    private static let STWINCONFIG_FIELD = BlueSTSDKFeatureField(name: FEATURE_DATA_NAME, unit: nil, type: .uInt8Array, min: NSNumber(value: Int8.min), max: NSNumber(value: Int8.max))
    private static let FIELDS = [STWINCONFIG_FIELD]
    private let dataTransporter = DataTransporter()
    private var commandManager: WriteDataManager?
    private let debug = true
    
    public var device: HSDDevice?
    public var deviceStatus: HSDDeviceStatus?
    public var tagConfig: HSDTagConfig?
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureHighSpeedDataLog.FEATURE_NAME)
        self.commandManager = WriteDataManager(feature: self)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureHighSpeedDataLog.FIELDS;
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        if let commandFrame = dataTransporter.decapsulate(data: data) {
            let response = HSDDeviceParser.responseFrom(data: commandFrame)
            let deviceStatus = HSDDeviceParser.deviceStatusFrom(data: commandFrame)
            let tagConfig = HSDDeviceParser.tagConfigFrom(data: commandFrame)
            
            if let device = response?.device {
                self.device = device
                self.tagConfig = device.tagConfig
            }
            
            if let deviceStatus = deviceStatus {
                self.deviceStatus = deviceStatus
            }
            
            if let tagConfig = tagConfig {
                self.tagConfig = tagConfig.tagConfig
            }
            
            self.tagConfig?.updateTypes()
            
            if debug {
                debugPrint(String(data: commandFrame, encoding: .utf8))
            }
            
            let sample = ConfigSample(device: response?.device, deviceStatus: deviceStatus, tagConfig: tagConfig?.tagConfig)
            return BlueSTSDKExtractResult(whitSample: sample, nReadData: UInt32(data.count))
        }
        
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }
    
    public func sendGetCommand(_ command: HSDGetCmd) {
        if debug {
            debugPrint("Send GET command: \(command.json ?? "--")")
        }
        
        sendCommand(command.json) {}
    }
    
    public func sendSetCommand(_ command: HSDSetCmd, completion: @escaping () -> Void) {
        if debug {
            debugPrint("Send SET command: \(command.json ?? "--")")
        }
        
        sendCommand(command.json, completion: completion)
    }
    
    public func sendControlCommand(_ command: HSDControlCmd) {
        if debug {
            debugPrint("Send CONTROL command: \(command.json ?? "--")")
        }
        
        sendCommand(command.json) {}
    }
    
    public func sendCommand(_ command: String?, completion: @escaping () -> Void) {
        sendWrite(dataTransporter.encapsulate(string: command), completion: completion)
    }
    
    private func sendWrite(_ data: Data, completion: @escaping () -> Void) {
        commandManager?.enqueueCommand(WriteDataManager.WriteData(data: data, completion: { _ in
            completion()
        }))
    }
}
