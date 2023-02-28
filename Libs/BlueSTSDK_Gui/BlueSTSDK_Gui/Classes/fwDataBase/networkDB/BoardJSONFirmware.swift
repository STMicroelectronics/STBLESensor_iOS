//
//  BoardJSONFirmware.swift

import Foundation

public struct BoardJSONFirmware: Codable {
    public let ble_dev_id: String
    public let ble_fw_id: String
    public let brd_name: String
    public let fw_version: String
    public let fw_name: String
    public let fota: String?
    public let partial_fota: String?
    public let characteristics: Array<BleJSONCharacteristic>?
    public let cloud_apps: Array<BleJSONCloudApps>?
    public let option_bytes: Array<OptionJSONByte>?

    enum CodingKeys: String, CodingKey {
        case ble_dev_id = "ble_dev_id"
        case ble_fw_id = "ble_fw_id"
        case brd_name = "brd_name"
        case fw_version = "fw_version"
        case fw_name = "fw_name"
        case fota = "fota"
        case partial_fota = "partial_fota"
        case characteristics = "characteristics"
        case cloud_apps = "cloud_apps"
        case option_bytes = "option_bytes"
    }


    public init(ble_dev_id: String, ble_fw_id: String, brd_name: String, fw_version: String, fw_name: String,
                fota: String?, partial_fota: String?, characteristics: Array<BleJSONCharacteristic>?, cloud_apps: Array<BleJSONCloudApps>?, option_bytes: Array<OptionJSONByte>?) {
        self.ble_dev_id = ble_dev_id
        self.ble_fw_id = ble_fw_id
        self.brd_name = brd_name
        self.fw_version = fw_version
        self.fw_name = fw_name
        self.fota = fota
        self.partial_fota = partial_fota
        self.characteristics = characteristics
        self.cloud_apps = cloud_apps
        self.option_bytes = option_bytes
    }
}
