//
//  PowerMode.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PowerMode {
    public enum Mode: String, Codable {
        case none = "NONE"
        case lowNoise = "LOW_NOISE"
        case lowCurrent = "LOW_CURRENT"
        case lowPower = "LOW_POWER"
        case lowPower2 = "LOW_POWER_2"
        case lowPower3 = "LOW_POWER_3"
        case lowPower4 = "LOW_POWER_4"
        case highPerformance = "HIGH_PERFORMANCE"
        case highResolution = "HIGH_RESOLUTION"
        case normalMode = "NORMAL_MODE"
        
        var identifier: Int {
            switch self {
            case .none:
                return 0
            case .lowNoise:
                return 1
            case .lowCurrent:
                return 2
            case .lowPower:
                return 3
            case .lowPower2:
                return 4
            case .lowPower3:
                return 5
            case .lowPower4:
                return 6
            case .highPerformance:
                return 7
            case .highResolution:
                return 8
            case .normalMode:
                return 9
            }
        }
    }
    
    let mode: Mode
    let label: String
    let odrs: [Double]
    let minCustomOdr: Double?
}

extension PowerMode: Codable {
    enum CodingKeys: String, CodingKey {
        case mode
        case label
        case odrs
        case minCustomOdr
    }
}

extension PowerMode: Checkable {
    var identifier: String {
        return "\(self.mode.identifier)"
    }

    var descr: String {
        return self.label
    }
}
