/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui

public class BlueSTSDKSTM32WBOTAUtils{
    /**
     *  local DB firmwares
     */
    public let catalogFw = CatalogService().currentCatalog()
    
    public static let OTA_NODE_ID = UInt8(0x86)
    
    /// defautl address were load the firmware
    public static let DEFAULT_FW_ADDRESS = UInt32(0x7000)
    
    /// tell if the node is a node where we can upload the firmware file
    ///
    /// - Parameter n: ble node
    /// - Returns: true if it is a otaNode
    public static func isOTANode(_ n:BlueSTSDKNode)->Bool{
        var retValue = false
        
        if(n.typeId ==  OTA_NODE_ID){
            retValue = true
        }
        if(n.protocolVersion == 0x02){

            /**1. Retrieve Option Bytes*/
            let optBytes = withUnsafeBytes(of: n.advertiseInfo.featureMap.bigEndian, Array.init)
            let optBytesData = NSData(bytes: optBytes, length: optBytes.count)
            //let optBytes2 = (n.advertiseInfo.featureMap).extractBeUInt32(fromOffset: <#T##UInt#>)
            let result0 = (optBytesData as NSData).extractUInt8(fromOffset: UInt(0))
            let result1 = (optBytesData as NSData).extractUInt8(fromOffset: UInt(1))
            let result2 = (optBytesData as NSData).extractUInt8(fromOffset: UInt(2))
            let result3 = (optBytesData as NSData).extractUInt8(fromOffset: UInt(3))
            let optBytesUnsigned = [result0, result1, result2, result3]
            
            if(CatalogService().currentCatalog() != nil){
                let fw_details = CatalogService().getFwDetailsNode(catalog: CatalogService().currentCatalog()!, device_id: Int(n.typeId & 0xFF), opt_byte_0: Int(result0), opt_byte_1: Int(result1))
                if !(fw_details==nil){
                    if(fw_details?.fota.type == .wbReady){
                        retValue = true
                    }
                }
            }
        }
        
        return retValue
    }
 
    
    /// get a map of uuid/feature class neede to manage the STM32WB OTA protocol
    ///
    /// - Returns: map of uuid/feature class neede to manage the STM32WB OTA protocol
    public static func getOtaCharacteristics() -> [CBUUID:[AnyClass]]{
        var temp:[CBUUID:[BlueSTSDKFeature.Type]]=[:]
        temp.updateValue([BlueSTSDKSTM32WBRebootOtaModeFeature.self], forKey: CBUUID(string: "0000fe11-8e22-4541-9d4c-21edae82ed19"))
        temp.updateValue([BlueSTSDKSTM32WBOTAControlFeature.self], forKey: CBUUID(string: "0000fe22-8e22-4541-9d4c-21edae82ed19"))
        temp.updateValue([BlueSTSDKSTM32WBOTAWillRebootFeature.self], forKey: CBUUID(string: "0000fe23-8e22-4541-9d4c-21edae82ed19"))
        temp.updateValue([BlueSTSDKSTM32WBOtaUploadFeature.self], forKey: CBUUID(string: "0000fe24-8e22-4541-9d4c-21edae82ed19"))
        return temp;
    }
    
    
    /// get the mac address that the node will have after rebooting in ota mode
    ///
    /// - Parameter n: node that will reboot
    /// - Returns: if the node has an address, the addres of the node when in ota mode
    public static func getOtaAddressForNode( _ n:BlueSTSDKNode)->String?{
        guard let address = n.address,
            var lastDigit = Int(address.suffix(2),radix:16) else {
            return nil
        }
        lastDigit = lastDigit+1
        return address.prefix( address.count-2).appending(String(format: "%02X",lastDigit))
    }
}
