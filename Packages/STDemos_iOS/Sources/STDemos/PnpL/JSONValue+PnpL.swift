//
//  JSONValue+PnpL.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import STBlueSDK
import STUI

extension JSONValue {
    func codeValues(with key: [String]) -> [any KeyValue] {

        var codeValues = [any KeyValue]()
        var keys = [String]()

        keys.append(contentsOf: key)

        switch self {
        case .object(let dictionary):
            for key in dictionary.keys {
                if let sensorDictionary = dictionary[key] {
                    var dictionaryKeys = [String]()
                    dictionaryKeys.append(contentsOf: keys)
                    dictionaryKeys.append(key)
                    codeValues.append(contentsOf: sensorDictionary.codeValues(with: dictionaryKeys))
                }
            }
        case .array(let array):
            for sensor in array {
                codeValues.append(contentsOf: sensor.codeValues(with: keys))
            }
        case .string(let string):
            codeValues.append(CodeValue<String>(keys: keys, value: string))
        case .int(let int):
            codeValues.append(CodeValue<Int>(keys: keys, value: int))
        case .double(let double):
            codeValues.append(CodeValue<Double>(keys: keys, value: double))
        case .bool(let bool):
            codeValues.append(CodeValue<Bool>(keys: keys, value: bool))
        }

        return codeValues
    }

//    func codeValues(with key: String) -> [any KeyValue] {
//
//        var codeValues = [any KeyValue]()
//
//        switch self {
//
//        case .object(let dictionary):
//            for path in dictionary.keys {
//                if let sensorVaelueDictionary = dictionary[path] {
//                    codeValues.append(contentsOf: sensorVaelueDictionary.codeValues(with: key, path: path))
//                }
//            }
//        case .array(let array):
//            for sensor in array {
//                codeValues.append(contentsOf: sensor.codeValues())
//            }
//        default:
//            break
//        }
//
//        return codeValues
//    }

//    func codeValues(with key: String, path: String) -> [any KeyValue] {
//
//        var codeValues = [any KeyValue]()
//
//        switch self {
//        case .string(let string):
//            codeValues.append(CodeValue<String>(keys: [ key, path ], value: string))
//        case .int(let int):
//            codeValues.append(CodeValue<Int>(keys: [ key, path ], value: int))
//        case .double(let double):
//            codeValues.append(CodeValue<Double>(keys: [ key, path ], value: double))
//        case .bool(let bool):
//            codeValues.append(CodeValue<Bool>(keys: [ key, path ], value: bool))
//        case .object(let dictionary):
//            codeValues.append(CodeValue<Bool>(keys: [ key, path ], value: bool))
//
//        default:
//            break
//        }
//
//        return codeValues
//    }
}
