//
//  ECCommand.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 27/04/21.
//

import Foundation

public enum ECCommandType: String {
    case UID = "UID"
    case versionFw = "VersionFw"
    case info = "Info"
    case help = "Help"
    case powerStatus = "PowerStatus"
    case changePIN = "ChangePIN"
    case clearDB = "ClearDB"
    case DFU = "DFU"
    case off = "Off"
    case bankStatus = "ReadBanksFwId"
    case bankSwap = "BanksSwap"
    
    case setTime = "SetTime"
    case setDate = "SetDate"
    case setWiFi = "SetWiFi"
    case setSensorsConfig = "SetSensorsConfig"
    case setName = "SetName"
    case setCert = "SetCert"

    case readCommand = "ReadCommand"
    case readCert = "ReadCert"
    case readSensorsConfig = "ReadSensorsConfig"
    case readCustomCommand = "ReadCustomCommand"
}

public extension ECCommandType {
    var title: String {
        "ext.command.\(rawValue).title"
    }
    
    var executedPhrase: String? {
        switch self {
            case .setDate, .setTime, .clearDB, .DFU, .off:
                return "ext.command.\(rawValue).executedPhrase"
            default:
                return nil
        }
    }
}

public struct ECCommand<T: Encodable>: Encodable {
    let command: String
    let argString: String?
    let argNumber: Int?
    let argJsonElement: T?
    
    public var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
    public var json: String? {
        if let data = jsonData,
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return nil
    }
    
    public init(name: String, argString: String? = nil, argNumber: Int? = nil, argJSON: T? = nil) {
        self.command = name
        self.argString = argString
        self.argNumber = argNumber
        self.argJsonElement = argJSON
    }
    
    public init(type: ECCommandType, argString: String? = nil, argNumber: Int? = nil, argJSON: T? = nil) {
        self.init(name: type.rawValue, argString: argString, argNumber: argNumber, argJSON: argJSON)
    }
    
    public func jsonWithHSDSetCommand(_ command: HSDSetCmd) -> String? {
        var serialized: EncodableDictionary = [
            "command": AnyEncodable(self.command),
            "argJsonElement": AnyEncodable(command.serialized)
        ]
        
        debugPrint(serialized)
        
        if let data = try? JSONEncoder().encode(serialized),
           let json = String(data: data, encoding: .utf8) {
            debugPrint(json)
            return json
        }
        
        return nil
    }
}
