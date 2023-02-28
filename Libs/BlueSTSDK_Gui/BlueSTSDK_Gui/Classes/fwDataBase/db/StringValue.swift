//
//  StringValue.swift

import Foundation

public class StringValue: NSObject, NSCoding {
    
    public var display_name: String?
    public var value: Int?
    
    enum Key:String {
        case display_name = "display_name"
        case value = "value"
    }
    
    init(display_name: String?, value: Int?) {
        self.display_name = display_name
        self.value = value
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(display_name, forKey: Key.display_name.rawValue)
        aCoder.encode(value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let mDisplayName = aDecoder.decodeObject(forKey: Key.display_name.rawValue) as? String
        let mValue = aDecoder.decodeObject(forKey: Key.value.rawValue) as? Int
        
        self.init(display_name: mDisplayName, value: mValue)
    }

}
