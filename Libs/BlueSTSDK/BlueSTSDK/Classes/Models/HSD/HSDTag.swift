//
//  HSDTag.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 29/01/21.
//

import Foundation

public class HSDTag: Codable, Hashable {
    public enum TagType: Int, Codable {
        case software
        case hardware
        
        public var title: String {
            switch self {
                case .software:
                    return "hsd.tag.software.title"
                case .hardware:
                    return "hsd.tag.hardware.title"
            }
        }
    }
    
    public static func == (lhs: HSDTag, rhs: HSDTag) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type?.rawValue ?? 0)
    }
    
    public let id: Int
    public var label: String
    public let pinDesc: String?
    public let enabled: Bool?
    
    public var type: TagType? = .software
}
