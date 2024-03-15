//
//  Output.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

final class Output: Checkable {
    var identifier: String
    var boardCompatibility: [String]?
    var itemIcon: String
    var descr: String
    var properties: [Property]?

    init(with identifier: String, itemIcon: String, descr: String) {
        self.identifier = identifier
        self.itemIcon = itemIcon
        self.descr = descr
    }
}

extension Output: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Output(with: self.identifier,
                          itemIcon: self.itemIcon,
                          descr: self.descr)
        
        copy.properties = self.properties
        
        return copy
    }
}

extension Output {
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

extension Output: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Output: Equatable {
    static func == (lhs: Output, rhs: Output) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Output: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case boardCompatibility = "board_compatibility"
        case itemIcon = "icon"
        case descr = "description"
        case properties
    }
}

extension Output: FlowItem {
    func hasSettings() -> Bool {
        return properties?.count ?? 0 > 0
    }
}

