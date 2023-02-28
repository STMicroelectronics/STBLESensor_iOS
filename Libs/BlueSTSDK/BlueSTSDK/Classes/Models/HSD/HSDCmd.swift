//
//  HSDCmd.swift
//  AWSCore
//
//  Created by Dimitri Giani on 20/01/21.
//

import Foundation

class AnyEncodable: Encodable {
    let value: Encodable
    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

typealias EncodableDictionary = [String: AnyEncodable]

public class HSDCmd: Encodable {
    public static let StartLogging = HSDControlCmd(command: "START")
    public static let StopLogging = HSDControlCmd(command: "STOP")
    public static let Save = HSDControlCmd(command: "SAVE")
    
    let command: String
    var serialized: EncodableDictionary {
        ["command": AnyEncodable(command)]
    }
    public var jsonData: Data? {
        try? JSONEncoder().encode(serialized)
    }
    public var json: String? {
        if let data = jsonData,
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return nil
    }
    
    public init(command: String) {
        self.command = command
    }
}

public class HSDControlCmd: HSDCmd {}
