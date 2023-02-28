//
//  Catalog.swift

import Foundation

public class Catalog: NSObject, NSCoding {
    
    public var checksum: String = ""
    public var date: String = ""
    public var version: String = ""
    public var bluestsdk_v2: [Firmware]?
    public var bluestsdk_v1: [Firmware]?
    public var characteristics: [Characteristic]?
    
    enum Key:String {
        case checksum = "checksum"
        case date = "date"
        case version = "version"
        case bluestsdk_v2 = "bluestsdk_v2"
        case bluestsdk_v1 = "bluestsdk_v1"
        case characteristics = "characteristics"
    }
    
    init(checksum: String, date: String, version: String, bluestsdk_v2: [Firmware]?, bluestsdk_v1: [Firmware]?, characteristics: [Characteristic]?) {
        self.checksum = checksum
        self.date = date
        self.version = version
        self.bluestsdk_v2 = bluestsdk_v2
        self.bluestsdk_v1 = bluestsdk_v1
        self.characteristics = characteristics
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(checksum, forKey: Key.checksum.rawValue)
        aCoder.encode(date, forKey: Key.date.rawValue)
        aCoder.encode(version, forKey: Key.version.rawValue)
        aCoder.encode(bluestsdk_v2, forKey: Key.bluestsdk_v2.rawValue)
        aCoder.encode(bluestsdk_v1, forKey: Key.bluestsdk_v1.rawValue)
        aCoder.encode(characteristics, forKey: Key.characteristics.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let m_checksum = aDecoder.decodeObject(forKey: Key.checksum.rawValue) as! String
        let m_date = aDecoder.decodeObject(forKey: Key.date.rawValue) as! String
        let m_version = aDecoder.decodeObject(forKey: Key.version.rawValue) as! String
        let m_bluestsdk_v2 = aDecoder.decodeObject(forKey: Key.bluestsdk_v2.rawValue) as? [Firmware]
        let m_bluestsdk_v1 = aDecoder.decodeObject(forKey: Key.bluestsdk_v1.rawValue) as? [Firmware]
        let m_characteristics = aDecoder.decodeObject(forKey: Key.characteristics.rawValue) as! [Characteristic]
        
        self.init(checksum: String(m_checksum), date: String(m_date), version: String(m_version), bluestsdk_v2: m_bluestsdk_v2, bluestsdk_v1: m_bluestsdk_v1, characteristics: m_characteristics)
    }

}

