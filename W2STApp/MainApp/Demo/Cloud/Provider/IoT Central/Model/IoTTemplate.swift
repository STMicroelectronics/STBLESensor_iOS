//
//  IoTTemplate.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

// MARK: - IoTTemplate
public struct IoTTemplate: Codable {
    public let etag: String?
    public let displayName: String
    public let capabilityModel: CapabilityModel?
    public let id: String
    public let types: [String]?
    public let solutionModel: SolutionModel?

    enum CodingKeys: String, CodingKey {
        case etag = "etag"
        case displayName = "displayName"
        case capabilityModel = "capabilityModel"
        case id = "@id"
        case types = "@types"
        case solutionModel = "solutionModel"
    }

    public init(etag: String?, displayName: String, capabilityModel: CapabilityModel?, id: String, types: [String]?, solutionModel: SolutionModel?) {
        self.etag = etag
        self.displayName = displayName
        self.capabilityModel = capabilityModel
        self.id = id
        self.types = types
        self.solutionModel = solutionModel
    }
}

// MARK: - CapabilityModel
public struct CapabilityModel: Codable {
    public let id: String?
    public let type: String?
    public let comment: String?
    public let contents: [Content]?
    public let displayName: String?
    public let implements: [JSONAny]?
    public let context: [String]?

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case comment = "comment"
        case contents = "contents"
        case displayName = "displayName"
        case implements = "implements"
        case context = "@context"
    }

    public init(id: String?, type: String?, comment: String?, contents: [Content]?, displayName: String?, implements: [JSONAny]?, context: [String]?) {
        self.id = id
        self.type = type
        self.comment = comment
        self.contents = contents
        self.displayName = displayName
        self.implements = implements
        self.context = context
    }
}

// MARK: - Content
public struct Content: Codable {
    public let type: TypeUnion?
    public let contentDescription: String?
    public let displayName: String?
    public let name: String?
    public let schema: SchemaUnion?
    public let unit: String?
    public let writable: Bool?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case contentDescription = "description"
        case displayName = "displayName"
        case name = "name"
        case schema = "schema"
        case unit = "unit"
        case writable = "writable"
    }

    public init(type: TypeUnion?, contentDescription: String?, displayName: String?, name: String?, schema: SchemaUnion?, unit: String?, writable: Bool?) {
        self.type = type
        self.contentDescription = contentDescription
        self.displayName = displayName
        self.name = name
        self.schema = schema
        self.unit = unit
        self.writable = writable
    }
}

public enum SchemaUnion: Codable {
    case schemaClass(SchemaClass)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(SchemaClass.self) {
            self = .schemaClass(x)
            return
        }
        throw DecodingError.typeMismatch(SchemaUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SchemaUnion"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .schemaClass(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

extension SchemaUnion {
    var schemaClass: SchemaClass? {
        if case SchemaUnion.schemaClass(let value) = self {
            return value
        }
        return nil
    }
    
    var schemaValue: String? {
        if case SchemaUnion.string(let value) = self {
            return value
        }
        return nil
    }
    
    var schemaType: SchemaClass.SchemaType {
        if let value = schemaValue {
            return SchemaClass.SchemaType(rawValue: value) ?? .unmanaged
        } else if let schemaClass = schemaClass {
            return schemaClass.schemaType
        }
        return .unmanaged
    }
}

// MARK: - SchemaClass
public struct SchemaClass: Codable {
    public enum SchemaType: String {
        case object = "Object"
        case double
        case string
        case unmanaged
    }
    
    public let type: String?
    public let enumValues: [EnumValue]?
    public let valueSchema: String?
    public let contents: [Content]?
    public let fields: [Field]?
    
    public var schemaType: SchemaType {
        SchemaType(rawValue: type ?? "unmanaged") ?? .unmanaged
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case enumValues = "enumValues"
        case valueSchema = "valueSchema"
        case contents = "contents"
        case fields = "fields"
    }

    public init(type: String?, enumValues: [EnumValue]?, valueSchema: String?, contents: [Content]?, fields: [Field]?) {
        self.type = type
        self.enumValues = enumValues
        self.valueSchema = valueSchema
        self.contents = contents
        self.fields = fields
    }
}

public struct Field: Codable {
    let name: String?
    let schema: SchemaUnion?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case schema = "schema"
    }
    
    init(name: String?, schema: SchemaUnion?) {
        self.name = name
        self.schema = schema
    }
}

// MARK: - EnumValue
public struct EnumValue: Codable {
    public let displayName: String?
    public let enumValue: Int?
    public let name: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "displayName"
        case enumValue = "enumValue"
        case name = "name"
    }

    public init(displayName: String?, enumValue: Int?, name: String?) {
        self.displayName = displayName
        self.enumValue = enumValue
        self.name = name
    }
}

public enum TypeUnion: Codable {
    case string(String)
    case stringArray([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String].self) {
            self = .stringArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(TypeUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TypeUnion"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .stringArray(let x):
            try container.encode(x)
        }
    }
}

// MARK: - SolutionModel
public struct SolutionModel: Codable {
    public let id: String?
    public let type: String?

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
    }

    public init(id: String?, type: String?) {
        self.id = id
        self.type = type
    }
}

// MARK: - Encode/decode helpers

public class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

public class JSONAny: Codable {

    public let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
