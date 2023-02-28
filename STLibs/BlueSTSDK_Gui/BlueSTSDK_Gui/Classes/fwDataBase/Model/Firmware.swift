//
//  Firmware.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Firmware {
    public let deviceId: String
    public let bleVersionIdHex: String
    public let boardName: String
    public let version: String
    public let name: String
    public let dtmi: String?
    public let cloudApps: [CloudApp]?
    public let characteristics: [BleCharacteristic]?
    public let optionBytes: [OptionByte]?
    public let description: String?
    public let changelog: String?
    public let fota: FotaDetails
}

extension Firmware: Codable {
    enum CodingKeys: String, CodingKey {
        case deviceId = "ble_dev_id"
        case bleVersionIdHex = "ble_fw_id"
        case boardName = "brd_name"
        case version = "fw_version"
        case name = "fw_name"
        case dtmi
        case cloudApps = "cloud_apps"
        case characteristics
        case optionBytes = "option_bytes"
        case description = "fw_desc"
        case changelog
        case fota
    }
}
