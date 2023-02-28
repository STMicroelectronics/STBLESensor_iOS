//
//  OptionJSONByte.swift

import Foundation

/** MODELING -> BLE OptionByte*/
public struct OptionJSONByte: Codable {
    public let format: String?
    public let name: String?
    public let negative_offset: Int?
    public let scale_factor: Int?
    public let type: String?
    public let string_values: Array<OptionByteEnumType>?
    public let icon_values: Array<OptionByteEnumType>?

    enum CodingKeys: String, CodingKey {
        case format = "format"
        case name = "name"
        case negative_offset = "negative_offset"
        case scale_factor = "scale_factor"
        case type = "type"
        case string_values = "string_values"
        case icon_values = "icon_values"
    }
    
    public init(format: String, name: String, negative_offset: Int, scale_factor: Int, type: String, string_values: Array<OptionByteEnumType>?, icon_values: Array<OptionByteEnumType>?) {
        self.format = format
        self.name = name
        self.negative_offset = negative_offset
        self.scale_factor = scale_factor
        self.type = type
        self.string_values = string_values
        self.icon_values = icon_values
    }
}

public struct OptionByteEnumType: Codable {
    public let type: String?
    public let display_name: String?
    public let comment: String?
    public let value: Int?
    public let icon_code: Int?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case display_name = "display_name"
        case comment = "comment"
        case value = "value"
        case icon_code = "icon_code"
    }
    
    public init(type: String, display_name: String, comment: String, value: Int, icon_code: Int) {
        self.type = type
        self.display_name = display_name
        self.comment = comment
        self.value = value
        self.icon_code = icon_code
    }
    
}
