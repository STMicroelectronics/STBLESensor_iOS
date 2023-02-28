//
//  IoTDeviceCredentials.swift
//  W2STApp
//
//  Created by Dimitri Giani on 07/07/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

struct IoTDeviceSymmetricKey: Codable {
    let primaryKey: String
}

struct IoTDeviceCredentials: Codable {
    let idScope: String
    let symmetricKey: IoTDeviceSymmetricKey
}
