//
//  Property.swift

import Foundation

public class CharacteristicFormat: NSObject, NSCoding {
    
    public var length: Int?
    public var name: String?
    public var unit: String?
    public var min: Float?
    public var max: Float?
    public var offset: Float?
    public var scalefactor: Float?
    public var type: String?
    
    enum Key:String {
        case length = "length"
        case name = "name"
        case unit = "unit"
        case min = "min"
        case max = "max"
        case offset = "offset"
        case scalefactor = "scalefactor"
        case type = "type"
    }
    
    init(length: Int?, name: String?, unit: String?, min: Float?, max: Float?, offset: Float?, scalefactor: Float?, type: String?) {
        self.length = length
        self.name = name
        self.unit = unit
        self.min = min
        self.max = max
        self.scalefactor = scalefactor
        self.type = type
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(length, forKey: Key.length.rawValue)
        aCoder.encode(name, forKey: Key.length.rawValue)
        aCoder.encode(unit, forKey: Key.length.rawValue)
        aCoder.encode(max, forKey: Key.length.rawValue)
        aCoder.encode(min, forKey: Key.length.rawValue)
        aCoder.encode(offset, forKey: Key.length.rawValue)
        aCoder.encode(scalefactor, forKey: Key.length.rawValue)
        aCoder.encode(type, forKey: Key.length.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let mLength = aDecoder.decodeObject(forKey: Key.length.rawValue) as? Int
        let mName = aDecoder.decodeObject(forKey: Key.name.rawValue) as? String
        let mUnit = aDecoder.decodeObject(forKey: Key.unit.rawValue) as? String
        let mMax = aDecoder.decodeObject(forKey: Key.max.rawValue) as? Float
        let mMin = aDecoder.decodeObject(forKey: Key.min.rawValue) as? Float
        let mOffset = aDecoder.decodeObject(forKey: Key.offset.rawValue) as? Float
        let mScaleFactor = aDecoder.decodeObject(forKey: Key.scalefactor.rawValue) as? Float
        let mType = aDecoder.decodeObject(forKey: Key.type.rawValue) as? String
        
        self.init(length: mLength, name: mName, unit: mUnit, min: mMin, max: mMax, offset: mOffset, scalefactor: mScaleFactor, type: mType)
    }

}
