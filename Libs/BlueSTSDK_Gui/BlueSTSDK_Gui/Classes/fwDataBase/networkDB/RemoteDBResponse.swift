//
//  RemoteDBResponse.swift

import Foundation

// MARK: - Modelling Board Firmwares JSON Response

public struct RemoteDBResponse: Codable {
    public let bluestsdk_v2: Array<BoardJSONFirmware>
    public let bluestsdk_v1: Array<BoardJSONFirmware>
    public let characteristics: Array<BleJSONCharacteristic>
    public let checksum: String
    public let date: String
    public let version: String

    enum CodingKeys: String, CodingKey {
        case bluestsdk_v2 = "bluestsdk_v2"
        case bluestsdk_v1 = "bluestsdk_v1"
        case characteristics = "characteristics"
        case checksum = "checksum"
        case date = "date"
        case version = "version"
    }
    
    public init(bluestsdk_v2: Array<BoardJSONFirmware>, bluestsdk_v1: Array<BoardJSONFirmware>, characteristics: Array<BleJSONCharacteristic>, checksum: String, date: String, version: String) {
        self.bluestsdk_v2 = bluestsdk_v2
        self.bluestsdk_v1 = bluestsdk_v1
        self.characteristics = characteristics
        self.checksum = checksum
        self.date = date
        self.version = version
    }
}
