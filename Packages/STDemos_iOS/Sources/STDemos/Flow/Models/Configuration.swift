//
//  Configuration.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

struct FilterConfiguration {
    var lowPass: Pass?
    var highPass: Pass?
}

extension FilterConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case lowPass
        case highPass
    }
}

extension FilterConfiguration {
    
    func jsonDictionary() -> [String: Any] {
        
        var filters: [String: Any] = [String: Any]()
        
        if let lowPass = lowPass {
            filters["lowPass"] = lowPass.jsonDictionary()
        }
        
        if let highPass = highPass {
            filters["highPass"] = highPass.jsonDictionary()
        }
        
        return filters
        
    }
}

public struct Configuration {
    
    public var time: Int?
    
    var acquisitionTime: Int? {
        get {
            return time
        }
        set {
            time = (newValue ?? 0) * 60
        }
    }
    public var powerMode: PowerMode.Mode?
    public var odr: Double?
    var filters: FilterConfiguration?
    public var fullScale: Int?
    var oneShotTime: Int?
    public var regConfig: String?
    public var ucfFilename: String?
    public var mlcLabels: String?
    var fsmLabels: String?
}

extension Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case time = "acquisitionTime"
        case powerMode
        case odr
        case filters
        case fullScale
        case oneShotTime
        case regConfig
        case ucfFilename
        case mlcLabels
        case fsmLabels
    }
}

extension Configuration: Equatable {
    public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        return lhs.acquisitionTime == rhs.acquisitionTime &&
            lhs.regConfig == rhs.regConfig &&
            lhs.ucfFilename == rhs.ucfFilename &&
            lhs.mlcLabels == rhs.mlcLabels &&
            lhs.fsmLabels == rhs.fsmLabels &&
            lhs.powerMode == rhs.powerMode &&
            lhs.odr == rhs.odr &&
            lhs.filters?.highPass?.value == rhs.filters?.highPass?.value &&
            lhs.filters?.lowPass?.value == rhs.filters?.lowPass?.value &&
            lhs.oneShotTime == rhs.oneShotTime
    }
}

extension Configuration {
    mutating func update(lowPass: Pass?) {
        if filters == nil {
            filters = FilterConfiguration(lowPass: nil, highPass: nil)
        }
        filters?.lowPass = lowPass
    }

    mutating func update(highPass: Pass?) {
        if filters == nil {
            filters = FilterConfiguration(lowPass: nil, highPass: nil)
        }
        filters?.highPass = highPass
    }
}

