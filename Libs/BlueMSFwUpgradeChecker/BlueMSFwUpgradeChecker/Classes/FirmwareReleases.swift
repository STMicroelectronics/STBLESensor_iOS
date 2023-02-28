//
//  FirmwareReleases.swift
//  BlueMSFwUpgradeChecker
//
//  Created by Giovanni Visentini on 06/05/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

struct FirmwareReleases :Codable {
    let lastUpdate:Date
    let firmwares:[DeviceFirmware]
}
