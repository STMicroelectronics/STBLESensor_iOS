//
//  MotorControlFault.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

enum MotorControlFault: Int {
    case none = 0
    case duration = 1
    case overVolt = 2
    case underVolt = 3
    case overTemp = 4
    case startUp = 5
    case speedFDBK = 6
    case breakIn = 7
    case swError = 8
    
    func getErrorStringFromCode() -> String {
        switch self {
        case .none:
            return "No Error"
        case .duration:
            return "FOC rate too high"
        case .overVolt:
            return "Software over voltage"
        case .underVolt:
            return "Software under voltage"
        case .overTemp:
            return "Software over temperature"
        case .startUp:
            return "Startup failed"
        case .speedFDBK:
            return "Speed feedback"
        case .breakIn:
            return "Emergency input (Over current)"
        case .swError:
            return "Software Error"
        }
    }
    
    static func getErrorCodeFromValue(code: Int) -> MotorControlFault {
        return MotorControlFault(rawValue: code) ?? .none
    }
}
