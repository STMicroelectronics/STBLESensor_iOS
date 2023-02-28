//
//  Catalog.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Catalog {
    public var blueStSdkV2: [Firmware]
    public var blueStSdkV1: [Firmware]
    public var characteristics: [BleCharacteristic]
    public let checksum: String
    public let date: String
    public let version: String
}

extension Catalog: Codable {
    enum CodingKeys: String, CodingKey {
        case blueStSdkV2 = "bluestsdk_v2"
        case blueStSdkV1 = "bluestsdk_v1"
        case characteristics
        case checksum
        case date
        case version
    }
}
