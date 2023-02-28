//
//  Sensor.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

final class Sensor: Checkable {
    var identifier: String
    var descr: String
    var icon: String
    var model: String
    var output: String
    var outputs: [String]?
    var uom: String?
    var datasheetLink: String?
    var notes: String?
    var dataType: String
    var powerMode: [PowerMode]?
    var configuration: Configuration?
    var acquisitionTime: Int?
    var fullScales: [Int]?
    var fullScaleUm:String?
    var bleMaxOdr: Double?

    init(with identifier: String, descr: String, icon: String, model: String, output: String, dataType: String) {
        self.identifier = identifier
        self.descr = descr
        self.icon = icon
        self.model = model
        self.output = output
        self.dataType = dataType
    }
}

extension Sensor: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Sensor(with: self.identifier,
                          descr: self.descr,
                          icon: self.icon,
                          model: self.model,
                          output: self.output,
                          dataType: self.dataType)
        
        copy.outputs = self.outputs
        copy.uom = self.uom
        copy.datasheetLink = self.datasheetLink
        copy.notes = self.notes
        copy.powerMode = self.powerMode
        copy.configuration = self.configuration
        copy.acquisitionTime = self.acquisitionTime
        copy.fullScales = self.fullScales
        copy.bleMaxOdr = self.bleMaxOdr
        
        return copy
    }
    
}

extension Sensor: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Sensor: Equatable {
    //someone has the god idea to add the same sensor with a different name..
    //to avoid confiusion..
    static func == (lhs: Sensor, rhs: Sensor) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.descr == rhs.descr
    }
}

extension Sensor: FlowItem {
    var itemIcon: String {
        return "img_memory"
    }
    
    func hasSettings() -> Bool {
        var result = false
        
        result = configuration?.powerMode != nil ? true : result
        result = configuration?.odr != nil ? true : result
        result = configuration?.filters != nil ? true : result
        result = configuration?.fullScale != nil ? true : result
        result = configuration?.acquisitionTime != nil ? true : result
        //SPR
        result = configuration?.regConfig != nil ? true : result
        
        return result
    }
}

extension Sensor: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case descr = "description"
        case icon
        case model
        case output
        case outputs
        case uom = "um"
        case datasheetLink
        case notes
        case dataType
        case powerMode = "powerModes"
        case configuration
        case acquisitionTime
        case fullScales
        case fullScaleUm
        case bleMaxOdr
    }
}

extension Sensor {
    func jsonDictionary() -> [String: Any] {
        var sensor: [String: Any] = [String: Any]()
        sensor["id"] = identifier
        if let powerMode = configuration?.powerMode {
            sensor["powerMode"] = powerMode.identifier
        }
        
        if let regConfig = configuration?.regConfig {
             var mlcConf = [
                "regConfig":regConfig
            ]
            if let mlcLabels = configuration?.mlcLabels {
                mlcConf["mlcLabels"] = mlcLabels
            }
            
            if let fsmLabels = configuration?.fsmLabels {
                mlcConf["fsmLabels"] = fsmLabels
            }
            sensor["configuration"] = mlcConf
        }
        
        if let odr = configuration?.odr {
            sensor["odr"] = odr
        }
        
        if let oneShotTime = configuration?.oneShotTime {
            sensor["odr"] = oneShotTime
        }
        
        if let fullscale = configuration?.fullScale {
            sensor["fullScale"] = fullscale
        }
        
        if let acquisitionTime = configuration?.acquisitionTime {
            sensor["acquisitionTime"] = acquisitionTime
        }

        if let filters = configuration?.filters {
            sensor["filter"] = filters.jsonDictionary()
        } else {
            sensor["filter"] = [:]
        }
        
        return sensor
    }
}

extension Sensor: CustomStringConvertible {
    var description: String {

        var properties = [String]()

        if let powerMode = configuration?.powerMode, powerMode != .none {
            properties.append("power_mode".localized())
        }
        
        if configuration?.odr != nil {
            properties.append("odr".localized())
        }
        
        if configuration?.filters != nil {
            properties.append("filter".localized())
        }
        
        if configuration?.fullScale != nil {
            properties.append("full_scale".localized())
        }
        
        return properties.isEmpty ? "-" : properties.joined(separator: ", ")
    }
}

struct FullScalePickable: Pickable {
    var value: Int
    var unit: String?

    func displayName() -> String {
        return "\(value) \(unit ?? "")"
    }
}
