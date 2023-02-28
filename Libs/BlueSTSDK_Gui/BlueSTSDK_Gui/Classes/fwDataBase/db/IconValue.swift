//
//  IconValue.swift

import Foundation

public class IconValue: NSObject, NSCoding {
    
    public var comment: String?
    public var icon_code: Int?
    public var value: Int?
    
    enum Key:String {
        case comment = "comment"
        case icon_code = "icon_code"
        case value = "value"
    }
    
    init(comment: String?, icon_code: Int?, value: Int?) {
        self.comment = comment
        self.icon_code = icon_code
        self.value = value
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(comment, forKey: Key.comment.rawValue)
        aCoder.encode(icon_code, forKey: Key.icon_code.rawValue)
        aCoder.encode(value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let mComment = aDecoder.decodeObject(forKey: Key.comment.rawValue) as? String
        let mIconCode = aDecoder.decodeObject(forKey: Key.icon_code.rawValue) as? Int
        let mValue = aDecoder.decodeObject(forKey: Key.value.rawValue) as? Int
        
        self.init(comment: mComment, icon_code: mIconCode, value: mValue)
    }

}
