//
//  PowerMode.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

struct PowerMode {
    enum Mode: String, Codable {
        case none = "NONE"
        case lowNoise = "LOW_NOISE"
        case lowCurrent = "LOW_CURRENT"
        case lowPower = "LOW_POWER"
        case lowPower2 = "LOW_POWER_2"
        case lowPower3 = "LOW_POWER_3"
        case lowPower4 = "LOW_POWER_4"
        case highPerformance = "HIGH_PERFORMANCE"
        case highResolution = "HIGH_RESOLUTION"
        
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
            }
        }
    }
    
    let mode: Mode
    let label: String
    let odrs: [Double]
    let minCustomOdr: Int?
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
