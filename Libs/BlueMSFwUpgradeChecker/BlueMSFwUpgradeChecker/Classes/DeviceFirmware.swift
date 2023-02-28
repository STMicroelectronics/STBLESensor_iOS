//
//  DeviceFirmware.swift
//  BlueMSFwUpgradeChecker
//
//  Created by Giovanni Visentini on 06/05/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

struct DeviceFirmware: Codable {
    let boardType: UInt8
    let name: String
    let mcu: String
    let relativeFwPath: String
    let versionMajor: Int
    let versionMinor: Int
    let versionPatch: Int
    
    enum CodingKeys: String, CodingKey {
        case  boardType = "boardType"
        case  name = "name"
        case  mcu = "mcu"
        case  relativeFwPath = "relativeFwPath"
        case  versionMajor = "version_major"
        case  versionMinor = "version_minor"
        case  versionPatch = "version_patch"
    }
    
}


extension Array where Element == DeviceFirmware{
    
    func filterUpgradeFirmwareFor(boardType: UInt8,name: String,mcu: String)->[DeviceFirmware]{
        return self.filter{ fw in
            return fw.boardType == boardType && fw.mcu == mcu && fw.name == name
        }
    }
}

