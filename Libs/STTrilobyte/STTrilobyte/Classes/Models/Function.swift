//
//  Function.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 16/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

final class Function: Checkable {
    var identifier: String
    var descr: String
    var inputs: [String]
    var mandatoryInputs: [[String]]
    var outputs: [String]
    
    var sensorInput: [String] {
        return inputs.filter { input -> Bool in input.contains("S") }
    }
    
    var functionInput: [String] {
        return inputs.filter { input -> Bool in input.contains("F") || input.contains("L") }
    }
    
    var parametersCount: Int
    var properties: [Property]?
    var maxRepeatCount: Int?

    init(with identifier: String, descr: String, inputs: [String], mandatoryInputs: [[String]], outputs: [String], parametersCount: Int) {
        self.identifier = identifier
        self.descr = descr
        self.inputs = inputs
        self.mandatoryInputs = mandatoryInputs
        self.outputs = outputs
        self.parametersCount = parametersCount
    }
}

extension Function: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Function(with: self.identifier,
                            descr: self.descr,
                            inputs: self.inputs,
                            mandatoryInputs: self.mandatoryInputs,
                            outputs: self.outputs,
                            parametersCount: self.parametersCount)
        
        copy.properties = self.properties
        copy.maxRepeatCount = self.maxRepeatCount
        
        return copy
    }
}

extension Function: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Function: Equatable {
    static func == (lhs: Function, rhs: Function) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Function {

    var isLogic: Bool {
        return identifier.contains(logicFunctionPrefix)
    }
    
    var isThreshold:Bool{
        return identifier == "L1"
    }

    func jsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [String: Any]()
        
        dictionary["id"] = identifier
        
        var propertiesArray: [[String: Any]] = [[String: Any]]()
        
        if let properties = self.properties {
            
            for property in properties {
                propertiesArray.append(property.jsonDictionary())
            }
            
            dictionary["values"] = propertiesArray
            
        }
        
        return dictionary
    }
}

extension Function: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case descr = "description"
        case inputs
        case mandatoryInputs
        case outputs
        case parametersCount
        case properties
        case maxRepeatCount
    }
}

extension Function: FlowItem {
    var itemIcon: String {
        return "img_function"
    }
    
    func hasSettings() -> Bool {
        return properties?.count ?? 0 > 0
    }
}
