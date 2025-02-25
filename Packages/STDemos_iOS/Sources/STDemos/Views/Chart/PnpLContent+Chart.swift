//
//  PnpLContent+Chart.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import STBlueSDK

public extension PnpLContent {

    var uom: String? {
        if case .interface(let interface) = self {
            for content in interface.contents {
                if case .property(let property) = content {
                    if property.name == "fs" {

                        var uomKey: String?

                        if let uom = property.displayUnit?.en {
                            uomKey = uom
                        }

                        if uomKey == nil {
                            uomKey = property.unit?.lowercased()
                        }

                        guard let uomKey = uomKey else { return nil }
                        
                        return uomKey.toShortUom()
//                        if uomKey == "gForce".lowercased() {
//                            return "g"
//                        } else if uomKey == "hertz".lowercased() {
//                            return "Hz"
//                        } else if uomKey == "gauss".lowercased() {
//                            return "G"
//                        } else if uomKey == "degreeCelsius".lowercased() {
//                            return "°C."
//                        } else if uomKey == "degreePerSecond".lowercased() {
//                            return "dps"
//                        } else if uomKey == "Waveform".lowercased() {
//                            return "dBSPL"
//                        } else {
//                            return nil
//                        }
                    }
                }
            }
        }

        return nil
    }

    func streamName() -> String? {
        if case .interface(let pnpLInterfaceContent) = self {
            for content in pnpLInterfaceContent.contents {
                if case .property(let pnpLPropertyContent) = content, pnpLPropertyContent.name == "st_ble_stream" {
                    if case .object(let pnpLContentSchema) = pnpLPropertyContent.schema {
                        for field in pnpLContentSchema.fields {
                            if case PnpLPrimitiveSchema.obj(let fieldContentObject) = field.schema,
                               case .object(let pnpLObjectContent) = fieldContentObject {
                                for childField in pnpLObjectContent.fields {
                                    if childField.name == "enable" {
                                        return field.name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return nil
    }

    func streamCommand(with value: Bool) -> PnpLCommand? {

        var jsonElement: String?
        var jsonParam: String?
        var jsonObject: String?
        let jsonObjectValue: String = "enable"

        if case .interface(let pnpLInterfaceContent) = self {
            jsonElement = pnpLInterfaceContent.displayName?.en
            for content in pnpLInterfaceContent.contents {
                if case .property(let pnpLPropertyContent) = content, pnpLPropertyContent.name == "st_ble_stream" {
                    jsonParam = pnpLPropertyContent.name
                    if case .object(let pnpLContentSchema) = pnpLPropertyContent.schema {
                        for field in pnpLContentSchema.fields {
                            if case PnpLPrimitiveSchema.obj(let fieldContentObject) = field.schema,
                               case .object(let pnpLObjectContent) = fieldContentObject {
                                for childField in pnpLObjectContent.fields {
                                    if childField.name == "enable" {
                                        jsonObject = field.name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        guard let jsonElement = jsonElement?.lowercased(),
              let jsonParam = jsonParam?.lowercased(),
              let jsonObject = jsonObject?.lowercased() else { return nil }

        return PnpLCommand.json(
            element: jsonElement,
            param: jsonParam,
            value: PnpLCommandValue.object(
                name: jsonObject,
                value: PnpLCommandValue.object(name: jsonObjectValue, value: AnyEncodable(value)).value
            )
        )
    }

    static func activeStreamContent(for streamdId: UInt8, device: PnPLDataModelDevice?, node: Node) -> PnpLContent? {

        guard let device = device else { return nil }

        if case JSONValue.array(let components) = device.components {
            for component in components {
                guard let streamConfig = component.searchKey(keyValue: "st_ble_stream"),
                      let streamIdentifier = streamConfig.searchKey(keyValue: "id"),
                      case JSONValue.int(let identifier) = streamIdentifier,
                      identifier == streamdId else { continue }

                if case JSONValue.object(let obj) = component,
                   let objectIdentifier = obj.keys.first {

                    if let dtmi = BlueManager.shared.dtmi(for: node),
                       let content = dtmi.contents.rawPnPLControlled.filter({ content in
                           return content.componentDisplayName?.lowercased() == objectIdentifier.lowercased()
                       }).first {
                        return content
                    }

                } else {
                    return nil
                }
            }
        }

        return nil
    }
}

extension String {
    func toShortUom() -> String {
        switch self {
            case "gForce": return "g"
            case "hertz": return "Hz"
            case "gauss": return "G"
            case "degreeCelsius": return "°C"
            case "degreePerSecond": return "dps"
            case "Waveform": return "dBSPL"
            default: return self
        }
    }
}
