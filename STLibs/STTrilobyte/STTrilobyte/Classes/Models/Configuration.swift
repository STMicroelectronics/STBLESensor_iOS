//
//  Configuration.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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

struct Configuration {
    
    private var time: Int?
    
    var acquisitionTime: Int? {
        get {
            return time
        }
        set {
            time = (newValue ?? 0) * 60
        }
    }
    var powerMode: PowerMode.Mode?
    var odr: Double?
    var filters: FilterConfiguration?
    var fullScale: Int?
    var oneShotTime: Int?
    var regConfig: String?
    var ucfFilename: String?
    var mlcLabels: String?
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
    static func == (lhs: Configuration, rhs: Configuration) -> Bool {
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
