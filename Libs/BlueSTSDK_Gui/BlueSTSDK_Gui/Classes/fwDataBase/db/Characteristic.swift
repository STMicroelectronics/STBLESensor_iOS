//
//  Characteristic.swift

import Foundation

public class Characteristic: NSObject, NSCoding {
    
    public var name: String = ""
    public var uuid: String = ""
    public var dtmi_name: String?
    public var description_charactertistic: String?
    public var format_notify: [CharacteristicFormat]?
    public var format_write: [CharacteristicFormat]?
    
    enum Key:String {
        case name = "name"
        case uuid = "uuid"
        case dtmi_name = "dtmi_name"
        case description_characteristic = "description"
        case format_notify = "format_notify"
        case format_write = "format_write"
    }
    
    init(name: String, uuid: String, dtmi_name: String?, description_characteristic: String?, format_notify: [CharacteristicFormat]?, format_write: [CharacteristicFormat]?) {
        self.name = name
        self.uuid = uuid
        self.dtmi_name = dtmi_name
        self.description_charactertistic = description_characteristic ?? ""
        self.format_notify = format_notify
        self.format_write = format_write
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Key.name.rawValue)
        aCoder.encode(uuid, forKey: Key.uuid.rawValue)
        aCoder.encode(dtmi_name, forKey: Key.dtmi_name.rawValue)
        aCoder.encode(description_charactertistic, forKey: Key.description_characteristic.rawValue)
        aCoder.encode(format_notify, forKey: Key.format_notify.rawValue)
        aCoder.encode(format_write, forKey: Key.format_write.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let mName = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let mUuid = aDecoder.decodeObject(forKey: Key.uuid.rawValue) as! String
        let mDtmiName = aDecoder.decodeObject(forKey: Key.dtmi_name.rawValue) as? String
        let mDescription = aDecoder.decodeObject(forKey: Key.description_characteristic.rawValue) as? String
        let mFormatNotify = aDecoder.decodeObject(forKey: Key.format_notify.rawValue) as? [CharacteristicFormat]
        let mFormatWrite = aDecoder.decodeObject(forKey: Key.format_write.rawValue) as? [CharacteristicFormat]
        
        self.init(name: String(mName), uuid: String(mUuid), dtmi_name: mDtmiName, description_characteristic: mDescription, format_notify: mFormatNotify, format_write: mFormatWrite)
    }

}
