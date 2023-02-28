//
//  BleJSONCloudApps.swift

import Foundation

/** MODELING -> BLE Cloud Apps*/
public struct BleJSONCloudApps: Codable {
    public let description: String?
    public let dtmi: String?
    public let name: String?
    public let shareable_link: String?
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case description = "description"
        case dtmi = "dtmi"
        case name = "name"
        case shareable_link = "shareable_link"
        case url = "url"
    }
    
    public init(description: String?, dtmi: String?, name: String?, shareable_link: String?, url: String?) {
        self.description = description
        self.dtmi = dtmi
        self.name = name
        self.shareable_link = shareable_link
        self.url = url
    }
}

