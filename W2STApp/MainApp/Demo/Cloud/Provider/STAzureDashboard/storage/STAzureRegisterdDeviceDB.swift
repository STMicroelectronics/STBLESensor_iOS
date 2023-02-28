//
//  RegisterdDeviceDB.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

internal class STAzureRegistredDeviceDB {
    
    static let instance = STAzureRegistredDeviceDB()
    
    let registerdDeviceDao: STAzureRegisterDeviceDao = STAzureRegisterdDeviceDaoCoreData()
    
}
