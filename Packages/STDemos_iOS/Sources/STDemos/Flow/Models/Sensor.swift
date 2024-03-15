//
//  Sensor.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public final class Sensor: Checkable {
    var identifier: String
    var boardCompatibility: [String]?
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

    public init(with identifier: String, descr: String, icon: String, model: String, output: String, dataType: String) {
        self.identifier = identifier
        self.descr = descr
        self.icon = icon
        self.model = model
        self.output = output
        self.dataType = dataType
    }
}

extension Sensor: NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
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
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Sensor: Equatable {
    //someone has the god idea to add the same sensor with a different name..
    //to avoid confiusion..
    public static func == (lhs: Sensor, rhs: Sensor) -> Bool {
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
        case boardCompatibility = "board_compatibility"
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
    public var description: String {

        var properties = [String]()

        if let powerMode = configuration?.powerMode, powerMode != .none {
            properties.append("Power mode")
        }
        
        if configuration?.odr != nil {
            properties.append("ODR")
        }
        
        if configuration?.filters != nil {
            properties.append("Filter")
        }
        
        if configuration?.fullScale != nil {
            properties.append("FS")
        }
        
        return properties.isEmpty ? "-" : properties.joined(separator: ", ")
    }
}

extension Sensor {
    public func sensorIconToImage(icon: String) -> UIImage? {
        switch icon {
        case "ic_accelerometer":
            return ImageLayout.image(with: "flow_sensor_accelerometer", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_humidity":
            return ImageLayout.image(with: "flow_sensor_humidity", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_inemo":
            return ImageLayout.image(with: "flow_sensor_inemo", in: .module)
        case "ic_magnetometer":
            return ImageLayout.image(with: "flow_sensor_magnetometer", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_microphone":
            return ImageLayout.image(with: "flow_sensor_microphone", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_nfc_sensor":
            return ImageLayout.image(with: "flow_sensor_nfc", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_pressure":
            return ImageLayout.image(with: "flow_sensor_pressure", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_qvar_sensor":
            return ImageLayout.image(with: "flow_sensor_qvar", in: .module)
        case "ic_rtc":
            return ImageLayout.image(with: "flow_sensor_rtc", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_termometer":
            return ImageLayout.image(with: "flow_sensor_temperature", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        case "ic_infrared":
            return ImageLayout.image(with: "flow_sensor_infrared", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        default:
            return ImageLayout.image(with: "flow_sensor_generic", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        }
    }
}

struct FullScalePickable: Pickable {
    var value: Int
    var unit: String?

    func displayName() -> String {
        return "\(value) \(unit ?? "")"
    }
}

protocol Checkable {
    var identifier: String { get }
    var descr: String { get }
}

struct FakeCheckable: Checkable {
    var identifier = ""
    var descr = ""
}
