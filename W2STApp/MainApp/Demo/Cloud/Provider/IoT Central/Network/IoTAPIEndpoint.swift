//
//  IoTAPIEndpoint.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Alamofire
import Foundation

enum IoTAPIEndpoint {
    static let accept = "application/json"
    static let jsonContentType = "application/json"
    static let version = "1.0"
    
    case templates
    case devices
    case createDevice(id: String)
    case getDeviceCredentials(id: String)
    case updateDevice(id: String)
    case deleteDevice(id: String)
    case deviceProperties(id: String)
    
    var path: String {
        switch self {
            case .templates:
                return "api/deviceTemplates?api-version=\(IoTAPIEndpoint.version)"
                
            case .devices:
                return "api/devices?api-version=\(IoTAPIEndpoint.version)"
                
            case .getDeviceCredentials(let id):
                return "api/devices/\(id)/credentials?api-version=\(IoTAPIEndpoint.version)"
                
            case .createDevice(let id),
                 .updateDevice(let id),
                 .deleteDevice(let id):
                return "api/devices/\(id)?api-version=\(IoTAPIEndpoint.version)"
                
            case .deviceProperties(let id):
                return "api/devices/\(id)/properties?api-version=\(IoTAPIEndpoint.version)"
        }
    }
}
