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

/// Write feature used to switch on and off the board led
public class STM32WBControlLedFeature : BlueSTSDKFeature{
    public typealias DeviceID = STM32WBPeer2PeerDemoConfiguration.DeviceID

    public static let FEATURE_NAME = "ControlLed";
    
    private static let SWITCH_ON_COMMAND:UInt8 = 1;
    private static let SWITCH_OFF_COMMAND:UInt8 = 0;
    
    
    /// build the feature to change the led status
    ///
    /// - Parameter node: node where the led will change
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: STM32WBControlLedFeature.FEATURE_NAME)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: []), nReadData: 0)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return []
    }
    
    
    /// switch off the led
    ///
    /// - Parameter device: remote node where switch off the led
    public func switchOffLed(device:DeviceID){
        let data = Data([device.rawValue,STM32WBControlLedFeature.SWITCH_OFF_COMMAND])
        write(data)
    }
    
    /// switch on the led
    ///
    /// - Parameter device: remote node where switch on the led
    public func switchOnLed(device:DeviceID){
        let data = Data([device.rawValue,STM32WBControlLedFeature.SWITCH_ON_COMMAND])
        write(data)
    }

}
