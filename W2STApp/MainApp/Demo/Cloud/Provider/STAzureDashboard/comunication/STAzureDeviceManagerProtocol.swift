//
//  STAzureDeviceManagerProtocol.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

internal enum STAzureDeviceRegistrationError : Error {
    case accessForbidden
    case invalidParameters
    case invalidResponse
    case offline
    case ioError
}

internal protocol STAzureDeviceManagerProtocol{
    
    typealias STAzureDeviceRegistrationResult = Result<STAzureRegisterdDevice,STAzureDeviceRegistrationError>
    typealias STAzureDeviceRegistrationCallback = (STAzureDeviceRegistrationResult)->()
    
    func register(deviceId:String,deviceName:String, onComplete:@escaping STAzureDeviceRegistrationCallback)
        
}
