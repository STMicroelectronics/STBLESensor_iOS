//
//  BlueSTSDKAnalyticsConnectionEvent.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 18/01/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation
import CommonCrypto

import BlueSTSDK

public class BlueSTSDKAnalyticsConnectionEvent :NSObject{
    public static let EVENT_NAME = "NodeConnection"
    public static let BOARD_TYPE_NAME_KEY = "Type_name"
    public static let BOARD_TYPE_ID_KEY = "Type_id"
    public static let NAME_KEY = "Name"
    public static let ADDRESS_KEY = "Address"
    public static let FW_NAME_KEY = "Fw_name"
    public static let FW_VERSION_KEY = "Fw_version"
    public static let APP_NAME_KEY = "App_name"
    public static let APP_VERSION_KEY = "App_version"
    private static let FW_UNKNOWN = "UNKNOWN"
    
    public let nodeName:String
    public let type:String
    public let typeId:String
    public let address:String
    public let fwName:String
    public let fwVersion:String
    public let appName:String
    public let appVersion:String
    
    
    public init(node:BlueSTSDKNode, version:BlueSTSDKFwVersion?){
        nodeName = node.name
        type = BlueSTSDKNode.nodeType(toString: node.type)
        typeId = "\(node.typeId)"
        address = BlueSTSDKAnalyticsConnectionEvent.obfuscate(node.addressEx())
        fwName = version?.name ?? BlueSTSDKAnalyticsConnectionEvent.FW_UNKNOWN
        if let version = version{
            fwVersion = "\(version.major).\(version.minor).\(version.patch)"
        }else{
            fwVersion = "0.0.0"
        }
        
        let bundle = Bundle.main;
        appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
        appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String;
        
    }
    
    private static func obfuscate(_ str:String)->String{
        let hash = sha256(str.data(using: .utf8)!)
        return dataToHex(hash);
    }
    
    static private func sha256(_ data:Data) ->Data{
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digest.withUnsafeMutableBytes { (outputBytes) in
            data.withUnsafeBytes { (inputBytes) in
                CC_SHA256(inputBytes, CC_LONG(data.count), outputBytes)
            }
        }
        return digest
    }
    
    static private func dataToHex(_ data:Data)->String{
        return data.map{String(format: "%02X",$0)}.joined()
    }

}
