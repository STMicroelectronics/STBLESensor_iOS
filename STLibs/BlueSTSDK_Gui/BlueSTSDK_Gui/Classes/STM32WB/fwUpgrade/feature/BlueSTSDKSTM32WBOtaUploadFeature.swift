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


/// write feature that will upload the file to the board
public class BlueSTSDKSTM32WBOtaUploadFeature : BlueSTSDKFeature{
    private static let FEATURE_NAME = "OTA File Upload";
    private static let FIELDS:[BlueSTSDKFeatureField] = [];
    private static let WRITE_DELAY:TimeInterval = 0.005;
    
    
    /// max package data length
    public static var CHUNK_LENGTH = 20;
    
    public func setChunkLength(chunkLength: Int) {
        BlueSTSDKSTM32WBOtaUploadFeature.CHUNK_LENGTH = chunkLength
        print("setChunkLength \(chunkLength)")
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKSTM32WBOtaUploadFeature.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKSTM32WBOtaUploadFeature.FEATURE_NAME)
    }
        
    /// Serial queue where the write operation are queued
    private let writeQueue = DispatchQueue(label: "BlueSTSDKSTM32WBOtaUploadFeature_writeQueue")
    
    /// upload the file content to the board. the data will be splitted in chunk of CHUNK_LENGTH bytes.
    ///
    /// - Parameters:
    ///   - file: data to upload
    ///   - onWrite: callback function called each time a chunk is sent. the parameters is the number of
    ///     byte sent
    public func upload(file:Data, onWrite:@escaping (UInt)->()){
        print("CHUNK LENGTH --> \(BlueSTSDKSTM32WBOtaUploadFeature.CHUNK_LENGTH)")
        let (quotient, rem) = file.count.quotientAndRemainder(dividingBy: BlueSTSDKSTM32WBOtaUploadFeature.CHUNK_LENGTH)
        let nChank = quotient + (rem == 0 ? 0 : 1)
        for i in 0..<nChank{
            writeQueue.async {
                let start = i*BlueSTSDKSTM32WBOtaUploadFeature.CHUNK_LENGTH;
                let stop = min((i+1)*BlueSTSDKSTM32WBOtaUploadFeature.CHUNK_LENGTH,file.count)
                let chank = file[start..<stop]
                self.write(chank)
                Thread.sleep(forTimeInterval: BlueSTSDKSTM32WBOtaUploadFeature.WRITE_DELAY)
                onWrite(UInt(stop))
            }
        }
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }
}
