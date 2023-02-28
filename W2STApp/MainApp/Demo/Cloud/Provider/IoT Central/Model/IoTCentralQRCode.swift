//
//  IoTCentralQRCode.swift
//  W2STApp
//
//  Created by Dimitri Giani on 23/08/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

struct IoTCentralQRCode: Codable {
    struct APIToken: Codable {
        let id: String
        let token: String
    }
    
    let appName: String
    let apitoken: APIToken
}
