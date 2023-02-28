//
//  HSDConfigSample.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 22/01/21.
//

import Foundation

public class ConfigSample: BlueSTSDKFeatureSample {
    public let device: HSDDevice?
    public let deviceStatus: HSDDeviceStatus?
    public let tagConfig: HSDTagConfig?
    
    public init(device: HSDDevice?, deviceStatus: HSDDeviceStatus?, tagConfig: HSDTagConfig?) {
        self.device = device
        self.deviceStatus = deviceStatus
        self.tagConfig = tagConfig
        
        super.init(whitData: [])
    }
}
