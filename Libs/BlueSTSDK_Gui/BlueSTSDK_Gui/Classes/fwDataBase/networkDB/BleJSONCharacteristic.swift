//
//  BleJSONCharacteristic.swift

import Foundation

/** MODELING -> BLE Characteristic*/
public struct BleJSONCharacteristic: Codable {
    public let name: String
    public let uuid: String
    public let dtmi_name: String?
    public let description: String?
    public let format_notify: Array<BleJSONCharacteristicFormat>?
    public let format_write: Array<BleJSONCharacteristicFormat>?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case uuid = "uuid"
        case dtmi_name = "dtmi_name"
        case description = "description"
        case format_notify = "format_notify"
        case format_write = "format_write"
    }
    
    public init(name: String, uuid: String, dtmi_name: String?, description: String?, format_notify: Array<BleJSONCharacteristicFormat>?, format_write: Array<BleJSONCharacteristicFormat>?) {
        self.name = name
        self.uuid = uuid
        self.dtmi_name = dtmi_name
        self.description = description
        self.format_notify = format_notify
        self.format_write = format_write
    }
}

public struct BleJSONCharacteristicFormat: Codable {
    public let length: Int?
    public let name: String
    public let unit: String?
    public let min: Float?
    public let max: Float?
    public let offset: Float?
    public let scalefactor: Float?
    public let type: String?

    enum CodingKeys: String, CodingKey {
        case length = "length"
        case name = "name"
        case unit = "unit"
        case min = "min"
        case max = "max"
        case offset = "offset"
        case scalefactor = "scalefactor"
        case type = "type"
    }
    
    public init(length: Int?, name: String, unit: String?, min: Float?, max: Float?, offset: Float?, scalefactor: Float?, type: String?) {
        self.length = length
        self.name = name
        self.unit = unit
        self.min = min
        self.max = max
        self.offset = offset
        self.scalefactor = scalefactor
        self.type = type
    }
}
