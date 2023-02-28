//
//  IoTResponse.swift
//  W2STApp
//
//  Created by Dimitri Giani on 26/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

struct IoTResponse<T: Codable>: Codable {
    let value: T
}
