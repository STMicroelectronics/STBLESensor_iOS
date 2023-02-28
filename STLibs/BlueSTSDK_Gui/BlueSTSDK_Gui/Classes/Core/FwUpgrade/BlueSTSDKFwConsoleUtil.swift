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

/// Utility class with factory method for obtaining the console object to interact with the fw
public class BlueSTSDKFwConsoleUtil{
    
    
    /// build the class used to retrive the firmware version running on the board
    ///
    /// - Parameter node: node to query
    /// - Returns: object to use for query the firmware version, null if not available
    public static func getFwReadVersionConsoleForNode(node:BlueSTSDKNode?)->BlueSTSDKFwReadVersionConsole?{
        guard let node = node else{
            return nil
        }
        
        if let stm32WbConsole = BlueSTSDKFwReadVersionConsoleSTM32WB(node: node){
            return stm32WbConsole;
        }
        
        if let blueNRGConsole = BlueNRGFwVersionConsole(node: node),
            node.type == .STEVAL_IDB008VX{
            return blueNRGConsole;
        }
        
        guard let console = node.debugConsole else {
            return nil
        }
        
        switch node.type {
        case .nucleo,.blue_Coin,.sensor_Tile,.STEVAL_BCN002V1,.sensor_Tile_Box,.SENSOR_TILE_BOX_PRO,
                .discovery_IOT01A, .STEVAL_STWINKIT1, .STEVAL_STWINKT1B, .STWIN_BOX:
                return BlueSTSDKFwUpgradeReadVersionNucleo(console: console);
            default:
                return nil;
        }
    }
    
    private static func stBoxHasNewFwUpgrade(version:BlueSTSDKFwVersion?) -> Bool{
        guard let version = version else{
            return false
        }
        let compareVersion = version.compare(BlueSTSDKFwVersion(major: 3, minor: 0, patch: 15))
        return compareVersion == .orderedSame || compareVersion == .orderedDescending
    }
    
    /// build the class used to retrive the firmware version running on the board
    ///
    /// - Parameter node: node to query
    /// - Returns: object to use for query the firmware version, null if not available
    public static func getFwUploadConsoleForNode(node:BlueSTSDKNode?, version:BlueSTSDKFwVersion?=nil)->BlueSTSDKFwUpgradeConsole?{
        guard let node = node else{
            return nil
        }
        
        if let stm32WbConsole = BlueSTSDKFwUpgradeConsoleSTM32WB(node: node){
            return stm32WbConsole;
        }
        
        if let blueNRGConsole = BlueNRGFwUpgradeConsole(node:node){
            return blueNRGConsole;
        }
        
        guard let console = node.debugConsole else {
            return nil
        }
        
        /** Check Fast Fota for Fw Update via Debug Console */
        var mFastFota = false

        let optBytes = withUnsafeBytes(of: node.advertiseInfo.featureMap.bigEndian, Array.init)
        
        var bleFwId: Int = 0
        if(optBytes[0]==0x00){
            bleFwId = Int(optBytes[1]) + 256
        }else if(optBytes[0]==0xFF){
            bleFwId = 255
        }else{
            bleFwId = Int(optBytes[0])
        }
        
        let catalogFw = CatalogService().currentCatalog()
        catalogFw?.blueStSdkV2.forEach{ fw in
            if(node.typeId == __uint8_t(fw.deviceId.dropFirst(2), radix: 16) &&  __uint8_t(fw.bleVersionIdHex.dropFirst(2), radix: 16)! == bleFwId) {
                if(fw.fota.type == .fast){
                    mFastFota = true
                }
            }
        }
        
        
        switch node.type {
        case .sensor_Tile_Box:
            if stBoxHasNewFwUpgrade(version: version) {
                return BlueSTSDKFwUpgradeConsoleNucleo2(console: console, packageDelayMs: 15);
            }else{
                return BlueSTSDKFwUpgradeConsoleNucleo(console: console, packageDelayMs: 30, fastFota: mFastFota);
            }
        case .nucleo,
             .blue_Coin,
             .sensor_Tile,
             .STEVAL_BCN002V1,
             .STEVAL_STWINKIT1,
             .STEVAL_STWINKT1B,
             .SENSOR_TILE_BOX_PRO,
             .discovery_IOT01A:
            return BlueSTSDKFwUpgradeConsoleNucleo(console: console, fastFota: mFastFota);
        default:
            return nil;
        }
    }
    
}
