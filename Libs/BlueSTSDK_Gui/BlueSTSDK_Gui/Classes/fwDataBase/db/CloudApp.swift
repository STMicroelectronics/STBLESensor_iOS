//
//  CloudApp.swift


import Foundation

public class CloudApp: NSObject, NSCoding {
    
    public var cloud_description: String?
    public var dtmi: String?
    public var name: String?
    public var shareable_link: String?
    public var url: String?
    
    enum Key:String {
        case cloud_description = "description"
        case dtmi = "dtmi"
        case name = "name"
        case shareable_link = "shareable_link"
        case url = "url"
    }
    
    init(cloud_description: String?, dtmi: String?, name: String?, shareable_link: String?, url: String?) {
        self.cloud_description = cloud_description
        self.dtmi = dtmi
        self.name = name
        self.shareable_link = shareable_link
        self.url = url
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(cloud_description, forKey: Key.cloud_description.rawValue)
        aCoder.encode(dtmi, forKey: Key.dtmi.rawValue)
        aCoder.encode(name, forKey: Key.name.rawValue)
        aCoder.encode(shareable_link, forKey: Key.shareable_link.rawValue)
        aCoder.encode(url, forKey: Key.url.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        
        let mDescription = aDecoder.decodeObject(forKey: Key.cloud_description.rawValue) as! String
        let mDtmi = aDecoder.decodeObject(forKey: Key.dtmi.rawValue) as! String
        let mName = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let mShareableLink = aDecoder.decodeObject(forKey: Key.shareable_link.rawValue) as! String
        let mUrl = aDecoder.decodeObject(forKey: Key.url.rawValue) as! String
        
        self.init(cloud_description: String(mDescription), dtmi: String(mDtmi), name: String(mName), shareable_link: String(mShareableLink), url: String(mUrl))
    }

}
