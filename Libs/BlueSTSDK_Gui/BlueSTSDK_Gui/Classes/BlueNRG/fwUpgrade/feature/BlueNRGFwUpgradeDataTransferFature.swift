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

class BlueNRGFwUpgradeDataTransferFeature : BlueSTSDKDeviceTimestampFeature {
    
    private static let FEATURE_NAME = "FwUpgradeDataTransfer";
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueNRGFwUpgradeDataTransferFeature.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueNRGFwUpgradeDataTransferFeature.FEATURE_NAME)
    }
    
    public func send(sequenceId:UInt16, data:Data, needAck:Bool) -> Bool{
        guard data.count + 4 <= parentNode.maximumWriteValueLength() else {
            return false
        }
        guard data.count % 16 == 0 else{
            return false
        }
        var dataToSend = Data(capacity: data.count+4)
        dataToSend.append(0) //crc
        dataToSend.append(contentsOf: data)
        dataToSend.append(needAck ? 1 : 0)
        var seqeunceIdLe = sequenceId.littleEndian
        dataToSend.append(UnsafeBufferPointer(start: &seqeunceIdLe, count: 1))
        dataToSend[0] = dataToSend.xor
        // print("Data: \((dataToSend as NSData).description) size:\(dataToSend.count)")
        write(dataToSend)
        return true
    }
    
    public func getMaxDataLength() -> UInt{
        // -4 for the crc + sequence + ack
        let maxDataLenght = UInt(parentNode.maximumWriteValueLength()) - 4
        let (nBlock,_) = maxDataLenght.quotientAndRemainder(dividingBy: 16)
        return 16*nBlock
    }
    
    override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }
    
}

fileprivate extension Data {
    
    var xor : UInt8 {
        get {
            return self.reduce(UInt8(0)){ xorSum, value in xorSum ^ value}
        }
    }
    
}
