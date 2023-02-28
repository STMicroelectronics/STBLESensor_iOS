//
//  Property.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

enum Descriptior {
    case bool(value: Bool)
    case float(value: Float)
    case radio(values: [RadioValue], selected: Int)
    case string(value: String)
    case intRange(value: Int, min:Int?, max: Int?)
    case unsupported
}

struct Property {
    let label: String
    var descriptor: Descriptior

    mutating func update(descriptor: Descriptior) {
        self.descriptor = descriptor
    }
}

extension Property {
    func jsonDictionary() -> [String: Any] {
        var propertyDictionary: [String: Any] = [String: Any]()
        propertyDictionary["label"] = label
        
        switch descriptor {
        case .bool(let value):
            propertyDictionary["value"] = value
        case .float(let value):
            propertyDictionary["value"] = value
        case .intRange(let value, _ , _):
            propertyDictionary["value"] = value
        case .string(let value):
            propertyDictionary["value"] = value
        case .radio(_, let selected):
            propertyDictionary["value"] = selected
        case .unsupported:
            break
        }
        
        return propertyDictionary
    }
}

extension Property: Equatable {
    static func == (lhs: Property, rhs: Property) -> Bool {
        return lhs.label == rhs.label
    }
}

extension Property: Codable {
    
    enum CodingKeys: String, CodingKey {
        case label
        case descriptor = "type"
        case value
        case enumValues
        case maxValue
        case minValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let label = try container.decode(String.self, forKey: .label)
        
        self.label = label
        
        let type = try? container.decode(String.self, forKey: .descriptor)
        switch type {
        case "BOOL":
            let value = try container.decode(Bool.self, forKey: .value)
            self.descriptor = Descriptior.bool(value: value)
        case "INT":
            let value = try container.decode(Int.self, forKey: .value)
            let max = try? container.decode(Int.self, forKey: .maxValue)
            let min = try? container.decode(Int.self, forKey: .minValue)
            self.descriptor = .intRange(value: value, min: min , max: max )
        case "FLOAT":
            let value = try container.decode(Float.self, forKey: .value)
            self.descriptor = Descriptior.float(value: value)
        case "STRING":
            let value = try container.decode(String.self, forKey: .value)
            self.descriptor = Descriptior.string(value: value)
        case "ENUM":
            let value = try container.decode(Int.self, forKey: .value)
            let radioValues = try container.decode([RadioValue].self, forKey: .enumValues)
            self.descriptor = Descriptior.radio(values: radioValues, selected: value)
        default:
            self.descriptor = Descriptior.unsupported
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        
        switch descriptor {
        case .bool(let value):
            try container.encode(value as Bool, forKey: .value)
            try container.encode("BOOL", forKey: .descriptor)
        case .intRange(let value, _,_):
            try container.encode(value as Int, forKey: .value)
            try container.encode("INT", forKey: .descriptor)
        case .float(let value):
            try container.encode(value as Float, forKey: .value)
            try container.encode("FLOAT", forKey: .descriptor)
        case .string(let value):
            try container.encode(value as String, forKey: .value)
            try container.encode("STRING", forKey: .descriptor)
        case .radio(let radioValues, let selected):
            try container.encode(selected as Int, forKey: .value)
            try container.encode("ENUM", forKey: .descriptor)
            try container.encode(radioValues as [RadioValue], forKey: .enumValues)
        default:
            throw EncodingError.invalidValue(descriptor, EncodingError.Context(codingPath: [], debugDescription: "The value is not encodable"))
        }
    }
    
}
