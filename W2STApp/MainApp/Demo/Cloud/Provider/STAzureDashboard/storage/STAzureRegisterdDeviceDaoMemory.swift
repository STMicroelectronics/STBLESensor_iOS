//
//  RegisterdDeviceDaoMemory.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

internal class STAzureRegisterdDeviceDaoMemory: STAzureRegisterDeviceDao {
    
    private var memoryDb:[String:STAzureRegisterdDevice] = [:]
    
    func getRegisterDevice(id: String) -> STAzureRegisterdDevice? {
        return memoryDb[id]
    }
    
    func add(device: STAzureRegisterdDevice) {
        memoryDb[device.id] = device
    }
    
    
}
