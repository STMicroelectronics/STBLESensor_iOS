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

/// Class used to notify the switch change status
public class STM32WBSwitchStatusFeature : BlueSTSDKDeviceTimestampFeature{
    
    public typealias DeviceID = STM32WBPeer2PeerDemoConfiguration.DeviceID
    
    public static let FEATURE_NAME = "SwitchInfo";
    public static let FEATURE_UNIT:String? = nil;
    public static let FEATURE_DATA_NAME = ["DeviceId","SwitchPressed"];
    public static let DATA_MIN = [0.0,0.0];
    public static let DATA_MAX = [6.0,1.0];
    
    /// Index for DEV ID Selection
    public static let SWITCH_STATUS_DEV_ID_INDEX=0;
    /// Index for button status Selection
    public static let SWITCH_STATUS_BUTTON_ID_INDEX=1;
    
    public static let fieldsDesc:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: FEATURE_DATA_NAME[SWITCH_STATUS_DEV_ID_INDEX],
                              unit: FEATURE_UNIT,
                              type: .uInt8,
                              min: NSNumber(value: DATA_MIN[SWITCH_STATUS_DEV_ID_INDEX]),
                              max: NSNumber(value: DATA_MAX[SWITCH_STATUS_DEV_ID_INDEX])),
        BlueSTSDKFeatureField(name: FEATURE_DATA_NAME[SWITCH_STATUS_BUTTON_ID_INDEX],
                              unit: FEATURE_UNIT,
                              type: .uInt8,
                              min: NSNumber(value: DATA_MIN[SWITCH_STATUS_BUTTON_ID_INDEX]),
                              max: NSNumber(value: DATA_MAX[SWITCH_STATUS_BUTTON_ID_INDEX]))
    ];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return STM32WBSwitchStatusFeature.fieldsDesc;
    }
    
    /// Build a switch status feature
    ///
    /// - Parameter node: node that will send data to this feature
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: STM32WBSwitchStatusFeature.FEATURE_NAME);
    }

    
    /// get the device that send the event
    ///
    /// - Parameter sample: event content
    /// - Returns: device that fire the event or nil if it is unknown
    public static func getDeviceSelection(sample:BlueSTSDKFeatureSample)->DeviceID?{
        if(sample.data.count>=SWITCH_STATUS_DEV_ID_INDEX){
            return DeviceID(rawValue: sample.data[SWITCH_STATUS_DEV_ID_INDEX].uint8Value)
        }else{
            return nil;
        }//if-else
    }
    
    
    /// tell if the switch is on or off
    ///
    /// - Parameter sample: event content
    /// - Returns: true if the button is pressed, false otherwise
    public static func getButtonPushed(sample:BlueSTSDKFeatureSample)->Bool{
        if(sample.data.count>=SWITCH_STATUS_BUTTON_ID_INDEX){
            let isPressed = sample.data[SWITCH_STATUS_BUTTON_ID_INDEX].uint8Value
            return isPressed == 0x01
        }else{
            return false;
        }//if-else
    }
 
    
    /// extract the feature data from the notification
    ///
    /// - Parameters:
    ///   - timestamp: event timestamp
    ///   - data: notification bytes
    ///   - offset: byte offset where the valid data starts
    /// - Returns: extracted data and byte read
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let off = Int(offset)
        if (data.count - off) < 2 {
            NSException(name: NSExceptionName(rawValue: "Invalid Button Status data "),
                              reason: "There are no 2 bytes available to read",
                              userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil , nReadData: 0);
        }
        let deviceId = data[off]
        let buttonStatus = data[off+1]
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data:
            [NSNumber(value: deviceId),NSNumber(value: buttonStatus)])
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 2)
    }
    
}
