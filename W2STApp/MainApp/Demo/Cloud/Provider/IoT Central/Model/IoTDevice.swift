//
//  IoTDevice.swift
//  W2STApp
//
//  Created by Dimitri Giani on 26/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

class IoTDevice: Codable {
    let id: String
    let etag: String
    var displayName: String
    let simulated: Bool
    let provisioned: Bool
    let template: String?
    let enabled: Bool
    
    var ioTtemplate: IoTTemplate? = nil
}

struct IoTDeviceTemporary: Encodable {
    var id: String
    var displayName: String
    var template: String
    var simulated: Bool = false
    var enabled: Bool = true
    
    var isValid: Bool {
        return  !id.isEmpty &&
                !displayName.isEmpty &&
                !template.isEmpty
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName, template, simulated, enabled
    }
}
