//
//  LoginManagerProtocol.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 27/08/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation

public protocol LoginManager {
    var provider: LoginProvider { get set }
    
    var isAuthenticated: Bool { get }

    func authenticate(from controller: UIViewController, completion: @escaping AuthCompletion)
    func resumeExternalUserAgentFlow(with url: URL) -> Bool
    func buildDeviceManager(completion: @escaping (Result<DeviceManager, DeviceOperationError>) -> Void)
}

public enum LoginProvider {
    case assetTracking
    case predictiveMaintenance
}
