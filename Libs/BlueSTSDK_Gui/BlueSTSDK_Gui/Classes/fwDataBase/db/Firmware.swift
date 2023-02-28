//
//  Firmware.swift

import Foundation

public class Firmware: NSObject, NSCoding {
    
    public var ble_dev_id: String = ""
    public var ble_fw_id: String = ""
    public var brd_name: String = ""
    public var fw_name: String = ""
    public var fw_version: String = ""
    public var fota: String?
    public var partial_fota: String?
    public var characteristics: [Characteristic] = []
    public var cloud_apps: [CloudApp]?
    public var option_bytes: [OptByte]?
    
    enum Key:String {
        case ble_dev_id = "ble_dev_id"
        case ble_fw_id = "ble_fw_id"
        case brd_name = "brd_name"
        case fota = "fota"
        case partial_fota = "partial_fota"
        case fw_name = "fw_name"
        case fw_version = "fw_version"
        case characteristics = "characteristics"
        case cloud_apps = "cloud_apps"
        case option_bytes = "option_bytes"
    }
    
    init(ble_dev_id: String, ble_fw_id: String, brd_name: String, fw_name: String, fw_version: String, fota: String?, partial_fota: String?, characteristics: [Characteristic], cloud_apps: [CloudApp]?, option_bytes: [OptByte]?) {
        self.ble_dev_id = ble_dev_id
        self.ble_fw_id = ble_fw_id
        self.brd_name = brd_name
        self.fota = fota
        self.partial_fota = partial_fota
        self.fw_name = fw_name
        self.fw_version = fw_version
        self.characteristics = characteristics
        self.cloud_apps = cloud_apps
        self.option_bytes = option_bytes
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(ble_dev_id, forKey: Key.ble_dev_id.rawValue)
        aCoder.encode(ble_fw_id, forKey: Key.ble_fw_id.rawValue)
        aCoder.encode(brd_name, forKey: Key.brd_name.rawValue)
        aCoder.encode(fota, forKey: Key.fota.rawValue)
        aCoder.encode(partial_fota, forKey: Key.partial_fota.rawValue)
        aCoder.encode(fw_name, forKey: Key.fw_name.rawValue)
        aCoder.encode(fw_version, forKey: Key.fw_version.rawValue)
        aCoder.encode(characteristics, forKey: Key.characteristics.rawValue)
        aCoder.encode(cloud_apps, forKey: Key.cloud_apps.rawValue)
        aCoder.encode(option_bytes, forKey: Key.option_bytes.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let m_ble_dev_id = aDecoder.decodeObject(forKey: Key.ble_dev_id.rawValue) as! String
        let m_ble_fw_id = aDecoder.decodeObject(forKey: Key.ble_fw_id.rawValue) as! String
        let m_brd_name = aDecoder.decodeObject(forKey: Key.brd_name.rawValue) as! String
        let m_fota = aDecoder.decodeObject(forKey: Key.fota.rawValue) as? String
        let m_partialFota = aDecoder.decodeObject(forKey: Key.partial_fota.rawValue) as? String
        let m_fw_name = aDecoder.decodeObject(forKey: Key.fw_name.rawValue) as! String
        let m_fw_version = aDecoder.decodeObject(forKey: Key.fw_version.rawValue) as! String
        let m_characteristics = aDecoder.decodeObject(forKey: Key.characteristics.rawValue) as! [Characteristic]
        let m_cloud_apps = aDecoder.decodeObject(forKey: Key.cloud_apps.rawValue) as? [CloudApp]
        let m_option_bytes = aDecoder.decodeObject(forKey: Key.option_bytes.rawValue) as? [OptByte]
        
        self.init(ble_dev_id: String(m_ble_dev_id), ble_fw_id: String(m_ble_fw_id), brd_name: String(m_brd_name), fw_name: String(m_fw_name), fw_version: String(m_fw_version), fota: m_fota, partial_fota: m_partialFota, characteristics: m_characteristics, cloud_apps: m_cloud_apps, option_bytes: m_option_bytes)
    }

}
