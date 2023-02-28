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


/// feature where wait a notification before the board will reboot with the new feature
public class BlueSTSDKSTM32WBOTAWillRebootFeature : BlueSTSDKDeviceTimestampFeature{
    private static let FEATURE_NAME = "OTA Will Reboot";
    private static let FIELDS:[BlueSTSDKFeatureField] = [];
    private static let REBOOT_OTA_MODE = UInt8(0x01);
    
    public static func isRebooting(_ sample:BlueSTSDKFeatureSample) -> Bool{
        return sample.data[0].boolValue;
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKSTM32WBOTAWillRebootFeature.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKSTM32WBOTAWillRebootFeature.FEATURE_NAME)
    }
    
    
    /// tell if the data receved contains a valid reboot message
    ///
    /// - Parameter sample: feature sample
    /// - Returns: true if the board is rebooting with the new firmware
    public static func boardIsRebooting(sample:BlueSTSDKFeatureSample) ->Bool{
        return sample.data[0].boolValue;
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let off = Int(offset)
        if (data.count - off) < 1 {
            NSException(name: NSExceptionName(rawValue: "Invalid OTAWillReboot data "),
                        reason: "There are no bytes available to read",
                userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let isRebooting = NSNumber(value: data[Int(offset)])
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: [isRebooting])

        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 1)
    }
}
