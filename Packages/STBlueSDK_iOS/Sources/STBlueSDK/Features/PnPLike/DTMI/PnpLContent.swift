//
//  PnpLContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public indirect enum PnpLContent {
    case interface(PnpLInterfaceContent)
    case component(PnpLComponentContent)
    case property(PnpLPropertyContent)
    case primitiveProperty(PnpLPrimitiveContent)
    case enumerative(PnpLEnumerativeContent)
    case object(PnpLObjectContent)
    case command(PnpLCommandContent)
    case commandPayload(PnpLCommandPayloadContent)
    case unknown(PnpLUnknownContent)

//    public func viewModel() -> any ViewModel {
//        fatalError()
//    }
}

extension PnpLContent: Codable {
    private enum CodingKeys: String, CodingKey {
        case type = "@type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()

        var type = try? container.decode(String.self, forKey: .type).lowercased()

        if type == nil, let detailedProperty = try? container.decode([String].self, forKey: .type) {
            type = detailedProperty.joined(separator: "|").lowercased()
        }
        
        if type == "interface" {
            let content = try singleContainer.decode(PnpLInterfaceContent.self)
            self = .interface(content)
        } else if type == "component" {
            let content = try singleContainer.decode(PnpLComponentContent.self)
            self = .component(content)
        } else if type == "property" {
            guard let content = try? singleContainer.decode(PnpLPropertyContent.self) else {
                let content = try singleContainer.decode(PnpLPrimitiveContent.self)
                self = .primitiveProperty(content)
                return
            }
            self = .property(content)
        } else if type?.contains("property")==true {
            if (type?.contains("vector")==true) ||
                (type?.contains("initialized")==true) ||
                (type?.contains("booleanvalue")==true) ||
                (type?.contains("numbervalue")==true) ||
                (type?.contains("stringvalue")==true) {
                
                guard let content = try? singleContainer.decode(PnpLPropertyContent.self) else {
                    let content = try singleContainer.decode(PnpLPrimitiveContent.self)
                    self = .primitiveProperty(content)
                    return
                }
                self = .property(content)
            } else {
             //Fallback
                let content = try singleContainer.decode(PnpLUnknownContent.self)
                self = .unknown(content)
            }
        } else if type == "enum" {
            let content = try singleContainer.decode(PnpLEnumerativeContent.self)
            self = .enumerative(content)
        } else if type == "object" {
            let content = try singleContainer.decode(PnpLObjectContent.self)
            self = .object(content)
        } else if type == "command" {
            let content = try singleContainer.decode(PnpLCommandContent.self)
            self = .command(content)
        } else if type == "commandpayload" {
            let content = try singleContainer.decode(PnpLCommandPayloadContent.self)
            self = .commandPayload(content)
        } else {
            //Fallback
            let content = try singleContainer.decode(PnpLUnknownContent.self)
            self = .unknown(content)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()

        switch self {
        case .interface(let pnpLInterfaceContent):
            try singleContainer.encode(pnpLInterfaceContent)
        case .component(let pnpLComponentContent):
            try singleContainer.encode(pnpLComponentContent)
        case .property(let pnpLPropertyContent):
            try singleContainer.encode(pnpLPropertyContent)
        case .primitiveProperty(let pnpLPrimitiveContent):
            try singleContainer.encode(pnpLPrimitiveContent)
        case .enumerative(let pnpLEnumerativeContent):
            try singleContainer.encode(pnpLEnumerativeContent)
        case .object(let pnpLObjectContent):
            try singleContainer.encode(pnpLObjectContent)
        case .command(let pnpLCommandContent):
            try singleContainer.encode(pnpLCommandContent)
        case .commandPayload(let pnpLCommandPayloadContent):
            try singleContainer.encode(pnpLCommandPayloadContent)
        case .unknown(let pnpLUnknownContent):
            try singleContainer.encode(pnpLUnknownContent)
        }
    }
}
