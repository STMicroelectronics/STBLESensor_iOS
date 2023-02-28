//
//  DeviceProfile.swift

import Foundation

public struct DeviceProfile: Decodable {
    public let owner: String
    public let createTimestamp: Double
    public let technology: String
    public let id: String
    public let context: DeviceProfileDetails
    public let converter: String?
    
    enum CodingKeys: String, CodingKey {
        case owner
        case createTimestamp = "create_timestamp"
        case technology
        case id
        case context
        case converter
    }
}

public struct DeviceProfileDetails: Codable {
    public let accessKey: String?
    public let secret: String?
    public let region: String?
    public let applicationId: String?
    public let applicationEui: String?
    public let applicationKey: String?
    public let apiKey: String?
    
    enum CodingKeys: String, CodingKey {
        case accessKey = "access_key"
        case secret
        case region
        case applicationId = "application_id"
        case applicationEui = "application_eui"
        case applicationKey = "application_key"
        case apiKey
    }
}
