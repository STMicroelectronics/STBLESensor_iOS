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

/// class to display the download progress
public class BlueSTSDKDownloadFileViewController : NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    
    private static let PROGRESS_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKDownloadFileViewController.self);
        return NSLocalizedString("%d/%ld bytes", tableName: nil,
                                 bundle: bundle,
                                 value: "%d/%ld bytes",
                                 comment: "%d/%ld bytes");
    }();
    
    private static let DOWNLOADING_STATUS_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKDownloadFileViewController.self);
        return NSLocalizedString("Downloading: %@", tableName: nil,
                                 bundle: bundle,
                                 value: "Downloading: %@",
                                 comment: "Downloading: %@");
    }();
    
    private static let DOWNLOADING_ERROR_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKDownloadFileViewController.self);
        return NSLocalizedString("Error: %@", tableName: nil,
                                 bundle: bundle,
                                 value: "Error: %@",
                                 comment: "Error: %@");
    }();
    
    
    private unowned let mDownloadProgressLabel:UILabel;
    private unowned let mDownloadStatusProgress:UILabel;
    private unowned let mDownloadProgressView:UIProgressView;
    private var mCompleteCallback:((URL)->())?;
    
    
    ///
    ///
    /// - Parameters:
    ///   - progressLabel: label where write the download progress
    ///   - statusLabel: label where write the download status
    ///   - progressView: progres view where display the download progress
    init( progressLabel:UILabel, statusLabel:UILabel ,progressView:UIProgressView ){
        mDownloadProgressLabel = progressLabel;
        mDownloadStatusProgress = statusLabel;
        mDownloadProgressView = progressView;
    }
    
    
    /// start to download a file from the url
    ///
    /// - Parameters:
    ///   - url: remote url from where start the download
    ///   - onComplete: callback done when the download ends, the parameter is the local url of the file
    public func downloadFile( url:URL, onComplete:@escaping (URL)->()){
    
        mCompleteCallback=onComplete;
        
        let config = URLSessionConfiguration.default;
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil);
        let task = urlSession.downloadTask(with: url);
        task.resume();
        let downloadStr = String(format:BlueSTSDKDownloadFileViewController.DOWNLOADING_STATUS_FORMAT,url.lastPathComponent);
        DispatchQueue.main.async { [weak self] in
            self?.mDownloadStatusProgress.text = downloadStr;
        }
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            let progressStr = String(format:BlueSTSDKDownloadFileViewController.PROGRESS_FORMAT,
                                     totalBytesWritten,totalBytesExpectedToWrite);
            DispatchQueue.main.async { [weak self] in
                self?.mDownloadProgressView.progress=progress;
                self?.mDownloadProgressLabel.text = progressStr;
            }
        }
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
            
        let requestResponse = downloadTask.response?.description
        
        if !(requestResponse==nil){
            if (requestResponse!.contains("Status Code: 200")){
                let fm = FileManager()
                    let newLocation = URL(fileURLWithPath: "Fw.tmp", relativeTo: fm.temporaryDirectory)
                    do{
                        if(fm.fileExists(atPath: newLocation.path)){
                            try fm.removeItem(at: newLocation)
                        }
                        try fm.copyItem(at: location, to: newLocation)
                        mCompleteCallback?(newLocation);
                    }catch{
                        DispatchQueue.main.async { [weak self] in
                            self?.mDownloadStatusProgress.text = "Error downloading the file";
                        }
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.mDownloadStatusProgress.text = "Error downloading the file"
                    return
                }
            }
        }
        
        

    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        if let err = error{
            let errorStr = String(format: "Error: %@", err.localizedDescription);
            DispatchQueue.main.async { [weak self] in
                self?.mDownloadStatusProgress.text = errorStr;
            }
        }
    }
}
