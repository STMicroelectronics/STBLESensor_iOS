//
//  PnPLikeDtmiCommands.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - PnPLikeElement
public struct PnPLikeElement: Codable {
    public let id: String
    public let type: String
    public let contents: [PnPLikeContent]
    public let displayName: DisplayName?
    public let context: [String]

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case context = "@context"
        case contents, displayName
    }
}

// MARK: - PnPLikeContent
public struct PnPLikeContent: Codable {
    public let id: String?
    public let type: TypeContent
    public let displayName: DisplayName
    public let name: String
    public let schema: SchemaContent?
    public let unit: String?
    public let writable: Bool?
    public let displayUnit: DisplayName?
    public let commandType: String?
    public let request: Request?
    public let response: EnumResponseValue?
    public let contentDescription: DisplayName?
    public let comment: String?

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case contentDescription = "description"
        case displayName, name, schema, unit, writable, commandType, request, response, comment, displayUnit
    }
}

public enum TypeContent: Codable {
    case string(String)
    case stringArray([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode([String].self) {
            self = .stringArray(x)
            return
        }
        throw DecodingError.typeMismatch(TypeContent.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TypeContent"))
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


// MARK: - Request
public struct Request: Codable {
    public let type: String
    public let displayName: DisplayName
    public let name: String
    public let schema: SchemaContent
    public let description: DisplayName?

    public enum CodingKeys: String, CodingKey {
        case type = "@type"
        case displayName, name, schema, description
    }
}


// MARK: - EnumResponseValue
public struct EnumResponseValue: Codable {
    public let displayName: DisplayName
    public let enumValue: Int?
    public let name: String
    public let id: String?
    public let schema: String?
    public let type: String?

    public enum CodingKeys: String, CodingKey {
        case displayName, enumValue, name, schema
        case id = "@id"
        case type = "@type"
    }
}

// MARK: - SchemaContent
public enum SchemaContent: Codable {
    case schemaObject(SchemaObject)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(SchemaObject.self) {
            self = .schemaObject(x)
            return
        }
        throw DecodingError.typeMismatch(SchemaContent.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ContentSchema"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .schemaObject(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - SchemaObject
public struct SchemaObject: Codable {
    public let id: String?
    public let type: String
    public let displayName: DisplayName
    public let enumValues: [EnumResponseValue]?
    public let valueSchema: String?
    public let fields: [EnumResponseValue]?
    public let writable: Bool?

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case displayName, enumValues, valueSchema, fields, writable
    }
}

// MARK: - DisplayName
public struct DisplayName: Codable {
    public let en: String
}

// MARK: - PnPLikeDtmiCommands
public typealias PnPLikeDtmiCommands = [PnPLikeElement]
