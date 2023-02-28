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

 
/// write feature used to control the file upload
public class BlueSTSDKSTM32WBOTAControlFeature : BlueSTSDKFeature{
    private static let FEATURE_NAME = "OTA Control";
    private static let FIELDS:[BlueSTSDKFeatureField] = [];
    private static let STOP_COMMAND = UInt8(0x00);
    private static let START_M0_COMMAND = UInt8(0x01);
    private static let START_M4_COMMAND = UInt8(0x02);
    private static let UPLOAD_FINISHED_COMMAND = UInt8(0x07);
    private static let CANCEL_COMMAND = UInt8(0x08);
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKSTM32WBOTAControlFeature.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKSTM32WBOTAControlFeature.FEATURE_NAME)
    }
    
    
    /// prepare the board to recevie the file
    ///
    /// - Parameters:
    ///   - type: type of fw that we are loading
    ///   - address: address where write the receved data
    public func startUpload( type: BlueSTSDKFwUpgradeType , address:UInt32){
        var bigEndianAddress = address.bigEndian
        let uploadType = type == .radioFirmware ?
            BlueSTSDKSTM32WBOTAControlFeature.START_M0_COMMAND :
            BlueSTSDKSTM32WBOTAControlFeature.START_M4_COMMAND
        var commandData = Data()
        commandData.append(UnsafeBufferPointer(start: &bigEndianAddress,count: 1))
        commandData[0] = uploadType
        write(commandData)
    }
    
    
    /// tell to the board that we finish to upload the file
    public func uploadFinished(){
        write(Data([BlueSTSDKSTM32WBOTAControlFeature.UPLOAD_FINISHED_COMMAND]))
    }
    
    /// tell to the board that we abort the file upload
    public func cancelUpload(){
        write(Data([BlueSTSDKSTM32WBOTAControlFeature.CANCEL_COMMAND]))
    }
    
    public func stopUpload(){
        write(Data([BlueSTSDKSTM32WBOTAControlFeature.STOP_COMMAND]))
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }
}
