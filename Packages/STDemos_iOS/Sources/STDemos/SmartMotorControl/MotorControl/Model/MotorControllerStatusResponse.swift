//
//  MotorControllerStatusResponse.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - MotorController
struct MotorControllerStatusResponse: Codable {
    let motorStatus: Bool
    let motorSpeed, cType: Int

    enum CodingKeys: String, CodingKey {
        case motorStatus = "motor_status"
        case motorSpeed = "motor_speed"
        case cType = "c_type"
    }
}
