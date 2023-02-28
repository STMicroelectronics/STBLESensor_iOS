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

 
/// Manage the view to display the fw upgrade progress
public class BlueSTSDKFwUpgradeProgressViewController: BlueSTSDKFwUpgradeConsoleCallback{
    
    
    private static let UPLOADING_MSG:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Flashing the new firmware", tableName: nil,
                                        bundle: bundle,
                                        value: "Flashing the new firmware",
                                        comment: "Flashing the new firmware");
    }();
    
    private static let PROGRESS_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("%d/%ld bytes", tableName: nil,
                                 bundle: bundle,
                                 value: "%d/%ld bytes",
                                 comment: "%d/%ld bytes");
    }();

    private static let UPLOAD_COMPLETE_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Upgrade completed in: %.2fs\nThe board is resetting", tableName: nil,
                                 bundle: bundle,
                                 value: "Upgrade completed in: %.2fs\nThe board is resetting",
                                 comment: "Upgrade completed in: %.2fs\nThe board is resetting");
    }();

    
    private static let CORRUPTED_DATA_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Transmitted data are corrupted", tableName: nil,
                                 bundle: bundle,
                                 value: "Transmitted data are corrupted",
                                 comment: "Transmitted data are corrupted");
    }();
    
    
    private static let TRANSMISION_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Error sending the data", tableName: nil,
                                 bundle: bundle,
                                 value: "Error sending the data",
                                 comment: "Error sending the data");
    }();
    
    private static let INVALID_FW_FILE_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Error while opening the file", tableName: nil,
                                 bundle: bundle,
                                 value: "Error while opening the file",
                                 comment: "Error while opening the file");
    }();
    
    private static let UNSUPPORTED_OPERATION_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Unsupported Operation", tableName: nil,
                                 bundle: bundle,
                                 value: "Unsupported Operation",
                                 comment: "Unsupported Operation");
    }();
    
    private static let UNKNOWN_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeProgressViewController.self);
        return NSLocalizedString("Unknown Error", tableName: nil,
                                 bundle: bundle,
                                 value: "Unknown Error",
                                 comment: "Unknown Error");
    }();
    
    
    private unowned let mUploadProgressLabel:UILabel;
    private unowned let mUploadStatusProgress:UILabel;
    private unowned let mUploadProgressView:UIProgressView;
    
    public var mFwUploadDelegate:BlueSTSDKFwUpgradeConsoleCallback?=nil;
    
    private var mFileLength:UInt=0;
    private var mStartUploadDate:Date = Date();

    
    ///
    /// - Parameters:
    ///   - progressLabel: label where write the upload progress
    ///   - statusLabel: label where write the fw upgrade status
    ///   - progressView: prgress view where display the fw upgrade progres
    init( progressLabel:UILabel, statusLabel:UILabel ,progressView:UIProgressView){
        mUploadProgressLabel = progressLabel;
        mUploadStatusProgress = statusLabel;
        mUploadProgressView = progressView;
    }

    
    /**
     * function called when the firmware file is correctly upload to the node
     * @param console object used to upload the file
     * @param file file upload to the board
     */
    public func onLoadComplite(file: URL) {
        mFwUploadDelegate?.onLoadComplite(file: file)
        let time = -mStartUploadDate.timeIntervalSinceNow;
        let message = String(format: BlueSTSDKFwUpgradeProgressViewController.UPLOAD_COMPLETE_FORMAT,
                             time);
        DispatchQueue.main.async {
            self.mUploadStatusProgress.text=message;
        }
    }
    

    /**
     * function called when the firmware file had an error during the uploading
     * @param console object used to upload the file
     * @param file file upload to the board
     * @param error error that happen during the upload
     */
    
    public func onLoadError(file: URL, error: BlueSTSDKFwUpgradeError) {
        let errorStr = BlueSTSDKFwUpgradeProgressViewController.getErrorString(error);
        DispatchQueue.main.async {
            self.mUploadStatusProgress.text = errorStr;
        }
    
    }
    
    
    private static func getErrorString(_ error:BlueSTSDKFwUpgradeError)->String{
        switch(error){
            case .corruptedFile:
                return CORRUPTED_DATA_ERR;
            case .trasmissionError:
                return TRANSMISION_ERR;
            case .invalidFwFile:
                return INVALID_FW_FILE_ERR;
            case .unsupportedOperation:
                return UNSUPPORTED_OPERATION_ERR;
            case .unknownError:
                return UNKNOWN_ERR;
        }//switch
    }
    
    private func updateProgressView( load:UInt){
        mUploadProgressView.progress = 1.0 - (Float(load))/Float(mFileLength)
        mUploadProgressLabel.text = String(format: BlueSTSDKFwUpgradeProgressViewController.PROGRESS_FORMAT,
                                           UInt(mFileLength-load),Int64(mFileLength))
    }
    
    public func onLoadProgres(file: URL, remainingBytes: UInt) {
        mFwUploadDelegate?.onLoadProgres(file: file, remainingBytes: remainingBytes)
        if(mFileLength==0){
            mFileLength = remainingBytes
            mStartUploadDate = Date()
            DispatchQueue.main.async {
                self.mUploadStatusProgress.text = BlueSTSDKFwUpgradeProgressViewController.UPLOADING_MSG
            }
        }
        DispatchQueue.main.async {
            self.updateProgressView(load: remainingBytes)
        }
    }
}
