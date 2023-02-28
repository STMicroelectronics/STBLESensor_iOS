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

/// Feature used to know the device connected in the network, the network can contain at maximum 6
///devices, for each device you can query if it is connected or not.
public class STM32WBNetworkStatusFeature : BlueSTSDKDeviceTimestampFeature{
    
    public typealias DeviceID = STM32WBPeer2PeerDemoConfiguration.DeviceID
    
    public static let FEATURE_NAME = "Network Status";
    public static let FEATURE_DATA_NAME_FORMAT = "Device %d";
    /** maximum value for the feature data */
    public static let DATA_MAX = 1;
    /** minimum value for the feature data */
    public static let DATA_MIN = 0;
    
    public static let MAX_MANAGED_DEVICE = 6;
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: STM32WBNetworkStatusFeature.FEATURE_NAME)
    }
    
    public let filedsDesc:[BlueSTSDKFeatureField] = {
        return  (1...STM32WBNetworkStatusFeature.MAX_MANAGED_DEVICE).map{ index in
            let name = String(format: STM32WBNetworkStatusFeature.FEATURE_DATA_NAME_FORMAT,index)
            return BlueSTSDKFeatureField(name: name,
                                         unit: nil,
                                         type: .uInt8,
                                         min: NSNumber(value: STM32WBNetworkStatusFeature.DATA_MIN),
                                         max: NSNumber(value: STM32WBNetworkStatusFeature.DATA_MAX))
        }//map
    }()
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return filedsDesc;
    }

    
    /// extract from the feature sample if a device is connected or not
    ///
    /// - Parameters:
    ///   - sample: feature sample
    ///   - device: device to query
    /// - Returns: true if the device is connected, false otherwise
    public static func isDeviceConnected(sample:BlueSTSDKFeatureSample, device:DeviceID )->Bool{
        let index = Int(device.rawValue)-1
        if(sample.data.count>index && index>=0){
            let isConnect = sample.data[index].uint8Value
            return isConnect == 0x01
        }else{
            return false
        }
    }

    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let off = Int(offset)
        if (data.count - off) < STM32WBNetworkStatusFeature.MAX_MANAGED_DEVICE {
            NSException(name: NSExceptionName(rawValue: "Invalid Network status data "),
                        reason: "There are no \(STM32WBNetworkStatusFeature.MAX_MANAGED_DEVICE) bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        var deviceStatus:[NSNumber] = []
        for  i in 0..<STM32WBNetworkStatusFeature.MAX_MANAGED_DEVICE{
            deviceStatus.append(NSNumber(value: data[off+i]))
        }
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data:deviceStatus)
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: UInt32(STM32WBNetworkStatusFeature.MAX_MANAGED_DEVICE))
    }
    
}
