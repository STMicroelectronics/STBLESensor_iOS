//
//  OptByte.swift

import Foundation

public class OptByte: NSObject, NSCoding {
    
    public var format: String?
    public var name: String?
    public var type: String?
    public var negative_offset: Int?
    public var scale_factor: Int?
    
    public var string_values: [StringValue]?
    public var icon_values: [IconValue]?
    
    enum Key:String {
        case format = "format"
        case name = "name"
        case type = "type"
        case negative_offset = "negative_offset"
        case scale_factor = "scale_factor"
        case string_values = "string_values"
        case icon_values = "icon_values"
    }
    
    init(format: String?, name: String?, type: String?, negative_offset: Int?, scale_factor: Int?, string_values: [StringValue]?, icon_values: [IconValue]?) {
        self.format = format
        self.name = name
        self.type = type
        self.negative_offset = negative_offset
        self.scale_factor = scale_factor
        self.string_values = string_values
        self.icon_values = icon_values
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(format, forKey: Key.format.rawValue)
        aCoder.encode(name, forKey: Key.name.rawValue)
        aCoder.encode(type, forKey: Key.type.rawValue)
        aCoder.encode(negative_offset, forKey: Key.negative_offset.rawValue)
        aCoder.encode(scale_factor, forKey: Key.scale_factor.rawValue)
        aCoder.encode(string_values, forKey: Key.string_values.rawValue)
        aCoder.encode(icon_values, forKey: Key.icon_values.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let mFormat = aDecoder.decodeObject(forKey: Key.format.rawValue) as? String
        let mName = aDecoder.decodeObject(forKey: Key.name.rawValue) as? String
        let mType = aDecoder.decodeObject(forKey: Key.type.rawValue) as? String
        let mNegativeOffset = aDecoder.decodeObject(forKey: Key.negative_offset.rawValue) as? Int
        let mScaleFactor = aDecoder.decodeObject(forKey: Key.scale_factor.rawValue) as? Int
        let mStringValues = aDecoder.decodeObject(forKey: Key.string_values.rawValue) as? [StringValue]
        let mIconValues = aDecoder.decodeObject(forKey: Key.icon_values.rawValue) as? [IconValue]
        
        self.init(format: mFormat, name: mName, type: mType, negative_offset: mNegativeOffset, scale_factor: mScaleFactor, string_values: mStringValues, icon_values: mIconValues)
    }

}
