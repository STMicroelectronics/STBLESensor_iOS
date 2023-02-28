//
//  RegisterdDeviceDao.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

internal protocol STAzureRegisterDeviceDao {
    func getRegisterDevice(id:String) -> STAzureRegisterdDevice?
    func add(device:STAzureRegisterdDevice)
}
