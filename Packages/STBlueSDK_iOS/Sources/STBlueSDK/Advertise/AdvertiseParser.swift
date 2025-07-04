//
//  BleAdvertiseParser.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

open class AdvertiseParser: AdvertiseFilter {
    
    private static let minProtocolVersionSupported: UInt8 = 0x01
    private static let maxProtocolVersionSupported: UInt8 = 0x02

    public init() {

    }
    
    open func filter(_ data: [String: Any]) -> AdvertiseInfo? {
        let txPower = data[CBAdvertisementDataTxPowerLevelKey] as? UInt8 ?? 0
        let name = data[CBAdvertisementDataLocalNameKey] as? String
        
        guard let vendorData = data[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return nil
        }
        
        let vendorDataCount = vendorData.count
        var offset = 0
        
        if ((vendorDataCount != 6) && (vendorDataCount != 12) && (vendorDataCount != 14)) {
            return nil
        }
        
        if ((vendorDataCount == 14) && (vendorData[0] != 0x30) &&  (vendorData[1] != 0x00)) {
            return nil
        } else if (vendorDataCount == 14) {
            offset = 2
        }
        
        let protocolVersion = vendorData[offset]
        guard protocolVersion >= AdvertiseParser.minProtocolVersionSupported &&
                protocolVersion <= AdvertiseParser.maxProtocolVersionSupported else {
            return nil
        }
        
        let deviceId = vendorData[1 + offset].nodeId
        let deviceType = getNodeType(deviceId: deviceId, protocolVersion: protocolVersion)
        let isSleeping = vendorData[1 + offset].isSleeping
        let hasGeneralPourpose = vendorData[1 + offset].hasGeneralPurpose
        let featureMap = vendorData.extractUInt32(fromOffset: 2 + offset, endian: .big)
        var address: String?
        if vendorDataCount != 6 {
            address = String(format: "%02X:%02X:%02X:%02X:%02X:%02X",
                             vendorData[6 + offset],
                             vendorData[7 + offset],
                             vendorData[8 + offset],
                             vendorData[9 + offset],
                             vendorData[10 + offset],
                             vendorData[11 + offset])
        }
        
        return BlueAdvertiseInfo(name: name,
                                 address: address,
                                 featureMap: featureMap,
                                 deviceId: deviceId,
                                 protocolVersion: protocolVersion,
                                 boardType: deviceType,
                                 isSleeping: isSleeping,
                                 hasGeneralPurpose: hasGeneralPourpose,
                                 txPower: txPower)
    }
}

extension AdvertiseParser {
    public func getNodeType(deviceId: UInt8, protocolVersion: UInt8) -> NodeType {
        if protocolVersion == 0x01 {
            //SDK V1
            switch deviceId {
            case 0x00:
                return .generic
            case 0x01:
                return .stevalWesu1
            case 0x02:
                return .sensorTile
            case 0x03:
                return .blueCoin
            case 0x04:
                return .stEvalIDB008VX
            case 0x05:
                return .stEvalBCN002V1
            case 0x06:
                return .sensorTileBox
            case 0x07:
                return .discoveryIOT01A
            case 0x08:
                return .stEvalSTWINKIT1
            case 0x09:
                return .stEvalSTWINKT1B
            case 0x0A:
                return .bL475eIot01A
            case 0x0B:
                return .bU585iIot02A
            case 0x0C:
                return .astra
            case 0x0D:
                return .sensorTileBoxPro
            case 0x0E:
                return .stWinBox
            case 0x0F:
                return .proteus
            case 0x10:
                return .stdesCBMLoRaBLE
            case 0x11:
                return .sensorTileBoxProB
            case 0x12:
                return .stWinBoxB
            case 0x13:
                return .sensorTileBoxProC
            case 0xC3:
                return .robKit1
            case 0x80:
                return .nucleo
            case 0x7F:
                return .nucleoF401RE
            case 0x7E:
                return .nucleoL476RG
            case 0x7D:
                return .nucleoL053R8
            case 0x7C:
                return .nucleoF446RE
            case 0x7B:
                return .nucleoU575ZIQ
            case 0x7A:
                return .nucleoU5A5ZJQ
            case 0x8D:
                return .nucleoWB0X
            case 0x8E:
                return .wba65RiNucleoBoard
            case 0x8F:
                return .wb05NucleoBoard
            case 0x90:
                return .wba2NucleoBoard
            case 0x91:
                return .wba5mWpanBoard
            case 0x92:
                return .stm32wba65iDk1Board
            case 0x9A:
                return .stm67w61MNucleoBoard
            case 0x86:
                return .wbOtaBoard
            case 0x81...0x8A:
                return .wb55NucleoBoard
            case 0x8B...0x8C:
                return .wba55CGNucleoBoard
            default:
                return .generic
            }
        } else {
            //SDK V2
            switch deviceId {
            case 0x00:
                return .generic
            case 0x01:
                return .stevalWesu1
            case 0x02:
                return .sensorTile
            case 0x03:
                return .blueCoin
            case 0x04:
                return .stEvalIDB008VX
            case 0x05:
                return .stEvalBCN002V1
            case 0x06:
                return .sensorTileBox
            case 0x07:
                return .discoveryIOT01A
            case 0x08:
                return .stEvalSTWINKIT1
            case 0x09:
                return .stEvalSTWINKT1B
            case 0x0A:
                return .bL475eIot01A
            case 0x0B:
                return .bU585iIot02A
            case 0x0C:
                return .astra
            case 0x0D:
                return .sensorTileBoxPro
            case 0x0E:
                return .stWinBox
            case 0x0F:
                return .proteus
            case 0x10:
                return .stdesCBMLoRaBLE
            case 0x11:
                return .sensorTileBoxProB
            case 0x12:
                return .stWinBoxB
            case 0x13:
                return .sensorTileBoxProC
            case 0xC3:
                return .robKit1
            case 0x80:
                return .nucleo
            case 0x7F:
                return .nucleoF401RE
            case 0x7E:
                return .nucleoL476RG
            case 0x7D:
                return .nucleoL053R8
            case 0x7C:
                return .nucleoF446RE
            case 0x7B:
                return .nucleoU575ZIQ
            case 0x7A:
                return .nucleoU5A5ZJQ
                
            //WB boards range 0x81->0x86
            case 0x81:
                return .wb55NucleoBoard
            case 0x82:
                return .stm32wb5mmDkBoard
            case 0x83:
                return .wb55UsbDoungleBoard
            case 0x84:
                return .wb15CCNucleoBoard
            case 0x85:
                return .wb1mWpan1Board
            case 0x86:
                return .wbOtaBoard
                
           //WBA boards  range 0x8B -> 0x8C
            case 0x8B:
                return .wba55CGNucleoBoard
            case 0x8C:
                return .stm32Wba55gDk1Board
            case 0x8D:
                return .nucleoWB0X
            case 0x8E:
                return .wba65RiNucleoBoard
            case 0x8F:
                return .wb05NucleoBoard
                
            case 0x90:
                return .wba2NucleoBoard
            case 0x91:
                return .wba5mWpanBoard
            case 0x92:
                return .stm32wba65iDk1Board
            case 0x9A:
                return .stm67w61MNucleoBoard
                
            default:
                return .generic
            }
        }
    }
}

fileprivate extension UInt8 {
    private static let nucleoBitMask: UInt8 = 0x80
    private static let isSleepingBitMask: UInt8 = 0x70
    private static let hasGeneralPurposeBitMask: UInt8 = 0x80
    
    private var isNucleo: Bool {
        get {
            return (self & UInt8.nucleoBitMask) != 0
        }
    }
    
    var nodeId: UInt8 {
        get {
            //if ((self & UInt8(0x80)) != 0) {
                return self
            //}
        }
    }
    
    var isSleeping: Bool {
        get {
            if ((self & UInt8.nucleoBitMask) != 0) {
                return false
            } else {
                return (self & UInt8.isSleepingBitMask) != 0
            }
        }
    }
    
    var hasGeneralPurpose: Bool {
        get {
            if ((self & UInt8.nucleoBitMask) != 0) {
                return false
            } else {
                return (self & UInt8.hasGeneralPurposeBitMask) != 0
            }
        }
    }
}

