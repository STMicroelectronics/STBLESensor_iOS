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

 public enum BlueSTSDKFwUpgradeError: Error{
    case corruptedFile
    case trasmissionError
    case invalidFwFile
    case unsupportedOperation
    case unknownError
 }
 
 public protocol BlueSTSDKFwUpgradeConsoleCallback{
    /**
     * function called when the firmware file is correctly upload to the node
     * @param console object used to upload the file
     * @param file file upload to the board
     */
    func onLoadComplite(file:URL);
    
    /**
     * function called when the firmware file had an error during the uploading
     * @param console object used to upload the file
     * @param file file upload to the board
     * @param error error that happen during the upload
     */
    func onLoadError(file:URL,error:BlueSTSDKFwUpgradeError);
    
    /**
     * function called during the file upload
     * @param console object used to upload the file
     * @param file file upload to the board
     * @param load number of bytes loaded to be load the board
     */
    func onLoadProgres(file:URL,remainingBytes:UInt);
 }
  
 public enum BlueSTSDKFwUpgradeType{
    case radioFirmware
    case applicationFirmware
 }
 
 public protocol BlueSTSDKFwUpgradeConsole{
    
    /// upload a file into the node
    ///
    /// - Parameters:
    ///   - type: type of firmware to upload, applicaiton firmware or radio fw
    ///   - file: file to upload
    ///   - delegate: object where notify the operation result
    ///   - address: address where upload the firmware (if needed)
    /// - Returns: true if the upload is started
    func loadFwFile(type:BlueSTSDKFwUpgradeType,
                    file:URL,
                    delegate:BlueSTSDKFwUpgradeConsoleCallback,
                    address:UInt32?)->Bool;
    
    
    /// valid range where a firmware can be uploaded, the default value is 0..UInt32.max
    var validAddressRange: Range<UInt32> {get}
    
 }
 
 public extension BlueSTSDKFwUpgradeConsole{
    var validAddressRange: Range<UInt32> { return UInt32.min..<UInt32.max}
 }
