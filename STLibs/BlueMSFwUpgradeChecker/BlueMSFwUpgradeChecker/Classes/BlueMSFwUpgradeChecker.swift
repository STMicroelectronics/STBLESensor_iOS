//
//  BlueMSFwUpgradeChecker.swift
//  BlueMSFwUpgradeChecker
//
//  Created by Giovanni Visentini on 06/05/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation
import BlueSTSDK

public class BlueMSFwUpgradeChecker {

    
    private static let BASE_URL = URL(string: "https://s3.amazonaws.com/st_test/STBLESensor/")!
    
    private static let LAST_RELEASES_URL = URL(string: "deviceFirmwareReleases.json", relativeTo: BASE_URL)!
    
    private let releasesRepository = FirmwareReleasesRepository(remoteDataUrl: BlueMSFwUpgradeChecker.LAST_RELEASES_URL)
    
    public init(){}
    
    public func checkNewFirmwareAvailabitity(boardType:UInt8,
                                             board:BlueSTSDKFwVersion,
                                             callback:@escaping (URL?)->Void){
        guard let fwName = board.name,
            let boardMcu = board.mcuType else{
                return
        }
        releasesRepository.loadFwReleases{ rel in
            let compatibleFw = rel?.firmwares.filterUpgradeFirmwareFor(boardType: boardType, name: fwName, mcu: boardMcu).first
            if let newFw = compatibleFw,
                board < newFw.version {
                    callback(BlueMSFwUpgradeChecker.buildFwAbsolutePath(fwInfo: newFw))
            }
        }
    }

    private static func buildFwAbsolutePath(fwInfo:DeviceFirmware)->URL?{
        return URL(string: fwInfo.relativeFwPath, relativeTo: BASE_URL)
    }
}

fileprivate extension DeviceFirmware {
    var version:BlueSTSDKFwVersion {
        get{
            return BlueSTSDKFwVersion(name: name, mcuType: mcu,
                                      major: versionMajor,
                                      minor: versionMinor,
                                      patch: versionPatch)
        }
    }
    
}

extension BlueSTSDKFwVersion : Comparable{
    public static func < (lhs: BlueSTSDKFwVersion, rhs: BlueSTSDKFwVersion) -> Bool {
        return lhs.compare(rhs) == .orderedAscending
    }
}
