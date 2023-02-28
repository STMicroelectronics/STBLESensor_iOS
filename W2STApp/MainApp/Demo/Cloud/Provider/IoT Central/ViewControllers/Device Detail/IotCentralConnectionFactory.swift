//
//  IotCentralConnectionFactory.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import BlueSTSDK
import SwiftyJSON
import BlueSTSDK_Gui

class IotCentralConnectionFactory: BlueMSAzureIotCentralConnectionFactory {
    
    static var dtmiNameOfBLEFeatures: [String:BlueSTSDKFeature] = [:]
    static var supportedFeatures: [BlueSTSDKFeature] = []
    var boardSupportedFeatures: [BleCharacteristic] = []
    var dtmiSupportedCharacteristics: [BleCharacteristic] = []
    /** Local DB firmwares */
    public var catalogFw: Catalog?
    
    
    weak var device: IoTDevice?
    var central: IoTCentralApp
    var credentials: IoTDeviceCredentials
    var node: BlueSTSDKNode
    
    init(device: IoTDevice, central: IoTCentralApp, credentials: IoTDeviceCredentials, node: BlueSTSDKNode) {
        self.device = device
        self.central = central
        self.credentials = credentials
        self.node = node
        
        super.init(deviceId: device.id, scopeId: credentials.idScope, sasKey: "", deviceSymmetricKey: credentials.symmetricKey.primaryKey)
        
        /**Retrieve Blue STSDK v2 firmware informations */
        catalogFw = CatalogService().currentCatalog()
        loadPnPData()
        
    }
    
    override func getFeatureDelegate(withSession session: BlueMSCloudIotClient, minUpdateInterval: TimeInterval) -> BlueSTSDKFeatureDelegate {
        return IotCentralFeatureListener(device: device)
    }
    
    override func isSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool {
        /** OLD METHOD
        var iotIsSupported = dtmiSupportedCharacteristics.contains(where: { $0.dtmiName?.lowercased() == feature.name.replacingOccurrences(of: " ", with: "_").lowercased() })
        */
        var iotIsSupported = dtmiSupportedCharacteristics.contains(where: { $0.dtmiName?.lowercased() == feature.name.replacingOccurrences(of: " ", with: "_").lowercased() })
         
        /** Associate BlueSTSDKFeature with its dtmi name */
        dtmiSupportedCharacteristics.forEach { char in
            if(char.dtmiName?.lowercased() == feature.name.replacingOccurrences(of: " ", with: "_").lowercased()){
                if let dtmiName = char.dtmiName {
                    IotCentralConnectionFactory.dtmiNameOfBLEFeatures[dtmiName] = feature
                }
            }
        }
        
        if(iotIsSupported){
            IotCentralConnectionFactory.supportedFeatures.append(feature)
        }else{
            let char = node.extractCharacteristics(from: feature)
            if !(char==nil){
                iotIsSupported = boardSupportedFeatures.contains(where: { $0.uuid.description == char!.uuid.description.lowercased() })
                if(iotIsSupported){
                    IotCentralConnectionFactory.supportedFeatures.append(feature)
                }
            }
        }
        
        return iotIsSupported
    }
    
    
    /**
     *  Function that load firmware informations from Local DB
     */
    func loadPnPData() {
        
        /**1. Retrieve Option Bytes*/
        let optBytes = withUnsafeBytes(of: node.advertiseInfo.featureMap.bigEndian, Array.init)
        print("optBytes0 -> \(optBytes[0]) and optBytes1 \(optBytes[1])")
        
        /**1. Retrieve Firmware Id*/
        var bleFwId: Int = 0
        if(optBytes[0]==0x00){
            bleFwId = Int(optBytes[1]) + 256
        }else if(optBytes[0]==0xFF){
            bleFwId = 255
        }else{
            bleFwId = Int(optBytes[0])
        }
        
        print("Board Type Id \(node.typeId)")
        print("Board Protocol Version \(node.advertiseInfo.protocolVersion)")
        print("Ble Fw Id \(bleFwId)")
        
        let remoteSupportedFeatures = device?.ioTtemplate?.supportedFeatureTypes ?? []
        
        catalogFw?.characteristics.forEach{ char in 
            if !(char.dtmiName==nil){
                let iotIsSupported = remoteSupportedFeatures.contains(where: { $0.lowercased() == char.dtmiName?.lowercased() })
    
                if(iotIsSupported){
                    dtmiSupportedCharacteristics.append(char)
                }
            }
        }

    }
}
