//
//  STAzureUserManagerProtocol.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

internal protocol STAzureAuthData{}

internal enum STAzureLoginError : Error {
    case accessForbidden
    case invalidParameters
    case invalidResponse
    case offline
    case ioError
}

internal protocol STAzureUserManagerProtocol{
    
    typealias STAzureLoginResult = Result<STAzureAuthData, STAzureLoginError>
    typealias STAzureLoginCallback = (STAzureLoginResult)->()
    
    func login(name:String,password:String, onComplete:@escaping STAzureLoginCallback)
    
    func getDeviceManager(authData:STAzureAuthData)->STAzureDeviceManagerProtocol?
    
}
