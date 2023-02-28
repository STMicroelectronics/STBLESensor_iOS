/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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

class BlueNRGFwUpgradeSettingsFeature : BlueSTSDKDeviceTimestampFeature {
    
    private static let FEATURE_NAME = "FwUpgradeSettings";
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "AckInterval", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt8.max)),
        BlueSTSDKFeatureField(name: "ImageSize", unit: nil, type: .uInt32,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt32.max)),
        BlueSTSDKFeatureField(name: "BaseAddress", unit: nil, type: .uInt32,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt32.max))
    ];
    
    public static func getAckInterval( _ sample :BlueSTSDKFeatureSample) -> UInt8{
        guard sample.data.count > 0 else {
            return UInt8.max
        }
        return sample.data[0].uint8Value
    }
    
    public static func getImageSize( _ sample :BlueSTSDKFeatureSample) -> UInt32{
        guard sample.data.count > 1 else {
            return UInt32.max
        }
        return sample.data[1].uint32Value
    }
    
    public static func getBaseAddress( _ sample :BlueSTSDKFeatureSample) -> UInt32{
        guard sample.data.count > 2 else {
            return UInt32.max
        }
        return sample.data[2].uint32Value
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueNRGFwUpgradeSettingsFeature.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueNRGFwUpgradeSettingsFeature.FEATURE_NAME)
    }
    
    public func set(ackInternval:UInt8, imageSize:UInt32, baseAddress:UInt32){
        var message = Data()
        message.append(ackInternval)
        var imageSizeLe = imageSize.littleEndian
        message.append(UnsafeBufferPointer(start: &imageSizeLe, count: 1))
        var baseAddressLe = baseAddress.littleEndian
        message.append(UnsafeBufferPointer(start: &baseAddressLe, count: 1))
        write(message)
    }
    
    override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        
        let availableData = data.count - Int(offset)
        if(availableData < 9){
            NSException(name: NSExceptionName(rawValue: "Invalid memory info data "),
                        reason: "There are no 9 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let uintOffset = UInt(offset)
        let ackInterval = data[0]
        let imageSize = (data as NSData).extractLeUInt32(fromOffset: uintOffset + 1)
        let baseAddress = (data as NSData).extractLeUInt32(fromOffset: uintOffset + 5)
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: [
            NSNumber(value: ackInterval),
            NSNumber(value: imageSize),
            NSNumber(value: baseAddress) ])
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 9)
    }
    
}
