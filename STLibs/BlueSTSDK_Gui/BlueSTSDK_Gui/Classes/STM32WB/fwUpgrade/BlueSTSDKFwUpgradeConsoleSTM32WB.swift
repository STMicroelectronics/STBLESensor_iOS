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


/// Fw Uograde protocol implemented for the STM32WB
class BlueSTSDKFwUpgradeConsoleSTM32WB : BlueSTSDKFwUpgradeConsole{
    
    var validAddressRange: Range<UInt32> = UInt32(0x7000)..<UInt32(0x089000)
    
    private let mControl : BlueSTSDKSTM32WBOTAControlFeature
    private let mUpload: BlueSTSDKSTM32WBOtaUploadFeature
    private let mWillReboot: BlueSTSDKSTM32WBOTAWillRebootFeature
    
    private let maximumWriteValueLength: Int
    
    /// build a fw upgrade console for the STM32WB, if all the needed characteristics are present
    ///
    /// - Parameter node: node where upload the new fw
    init?(node:BlueSTSDKNode){
        maximumWriteValueLength = node.maximumWriteValueLength()
        if let control = node.getFeatureOfType(BlueSTSDKSTM32WBOTAControlFeature.self) as? BlueSTSDKSTM32WBOTAControlFeature,
            let upload =  node.getFeatureOfType(BlueSTSDKSTM32WBOtaUploadFeature.self) as? BlueSTSDKSTM32WBOtaUploadFeature,
            let reboot =  node.getFeatureOfType(BlueSTSDKSTM32WBOTAWillRebootFeature.self) as? BlueSTSDKSTM32WBOTAWillRebootFeature{
                mControl = control
                mUpload = upload
                mWillReboot = reboot
        }else{
            return nil
        }
    }
    
    func loadFwFile(type: BlueSTSDKFwUpgradeType,
                    file: URL,
                    delegate: BlueSTSDKFwUpgradeConsoleCallback,
                    address:UInt32?) -> Bool {
        guard let address = address else {
            return false
        }
        
        let willRebootDelegate = WillRebootDelegate(delegate: delegate, file: file);
        do{
            mWillReboot.add(willRebootDelegate)
            mWillReboot.enableNotification()
            let fileHandler = try FileHandle(forReadingFrom: file)
            let data = fileHandler.readDataToEndOfFile()
            let fileSize = UInt(data.count)
            fileHandler.closeFile()
            
            mUpload.setChunkLength(chunkLength: maximumWriteValueLength)

            mControl.startUpload(type: type, address: address)
            mUpload.upload(file: data){ [control = mControl] byteSent in
                delegate.onLoadProgres(file: file, remainingBytes: fileSize - byteSent)
                if(byteSent == fileSize){
                    control.uploadFinished()
                }//if
            }//upload
        }catch{
            delegate.onLoadError(file: file, error: .invalidFwFile)
            return false;
        }
        return true;
    }
}
 
 
 /// delecate called when the node receve the reboot indication -> the fw upload is finisched
 fileprivate class WillRebootDelegate : NSObject, BlueSTSDKFeatureDelegate{
    
    private let delegate: BlueSTSDKFwUpgradeConsoleCallback
    private let fileUrl : URL
    
    init(delegate: BlueSTSDKFwUpgradeConsoleCallback, file:URL) {
        self.delegate = delegate
        self.fileUrl = file
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if(BlueSTSDKSTM32WBOTAWillRebootFeature.isRebooting(sample)){
            delegate.onLoadComplite(file: self.fileUrl)
        }else{
            delegate.onLoadError(file: self.fileUrl, error: .trasmissionError)
        }
        feature.remove(self)
    }
 }
