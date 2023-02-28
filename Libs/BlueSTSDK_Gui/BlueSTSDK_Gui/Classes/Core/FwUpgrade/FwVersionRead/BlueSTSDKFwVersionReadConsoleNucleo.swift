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

/// class implementing the protocol to know the fw version for the nucleos boards
public class BlueSTSDKFwUpgradeReadVersionNucleo : BlueSTSDKFwReadVersionConsole{
    
    
    /// string to send to get back the Fw version
    private static let GET_FW_VERSION = "versionFw\r\n"
    
    /// callback to call when the fw version is received
    private var onComplateCallback:((BlueSTSDKFwVersion?) -> ())?
    
    
    /// console to use to comunicate with the board
    private var mConsole:BlueSTSDKDebug
    
    /// delegate to use to receve the message from the board
    private var mConsoleDelegate:BlueSTSDKFwReadVersionConsoleDelegate?
    
    public init(console:BlueSTSDKDebug){
        mConsole = console
    }
    
    
    /// ask for the firmware version
    ///
    /// - Parameter onComplete: callback called when the request end, the version
    ///   is null if the request fail/is not available
    /// - Returns: true if the request is correctly send, false otherwise
    public func readFwVersion(onComplete: @escaping (BlueSTSDKFwVersion?) -> ()) -> Bool {
        guard mConsoleDelegate==nil else {
            return false;
        }
        
        mConsoleDelegate = BlueSTSDKFwReadVersionConsoleDelegate{ version in
            self.mConsoleDelegate = nil
            onComplete(version)
        }
        mConsole.add(mConsoleDelegate!)
        
        mConsole.writeMessage(BlueSTSDKFwUpgradeReadVersionNucleo.GET_FW_VERSION)
        return true;
    }
    
    
}

fileprivate class BlueSTSDKFwReadVersionConsoleDelegate :BlueSTSDKDebugOutputDelegate{
    
    /// after 1 second we parse the response, also if the text is not completed
    private static let COMMAND_TIMEOUT_S = 1.0
    
    //serial queue where post the timeout item
    private let mTimeoutQueue = DispatchQueue(label: "BlueSTSDKFwReadVersionConsoleDelegate")
    //timeout callback
    private var mTimeoutCall:DispatchWorkItem?
    
    private var mResponse = "";
    private var mOnCompleteCallback:((BlueSTSDKFwVersion?) -> ())?
    
    init(onComplete:@escaping (BlueSTSDKFwVersion?) -> ()) {
        mOnCompleteCallback = onComplete
    }
    
    private func callUserCallback(version: BlueSTSDKFwVersion?){
        self.mOnCompleteCallback?(version)
        //set it to null to be secure to do only one callback to the user
        self.mOnCompleteCallback = nil
    }
    
    /// set the timeout
    private func setTimeout(){
        if(mTimeoutCall != nil){
            removeTimeout()
        }
        mTimeoutCall = DispatchWorkItem{ [weak self] in
            guard let self = self else{
                return
            }
            //lets try to dectect the version form the data that we have
            self.callUserCallback(version: BlueSTSDKFwVersion(self.mResponse))
        }
        mTimeoutQueue.asyncAfter(deadline: .now() + BlueSTSDKFwReadVersionConsoleDelegate.COMMAND_TIMEOUT_S,
                                 execute: mTimeoutCall!)
    }
    
    /// cancel the timeout
    private func removeTimeout(){
        mTimeoutCall?.cancel()
        mTimeoutCall=nil;
    }
    
    ///call when we receve and answare
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        //we serialize the execution of the function to be secure to elaborate only the first line
        // in case the console will print also ther things.. 
        mTimeoutQueue.sync { [weak self] in
            guard let self = self else{
                 return
            }
            self.mResponse.append(msg)
            if(BlueSTSDKFwReadVersionConsoleDelegate.isCompeteLine(mResponse)){
                removeTimeout()
                debug.remove(self)
                self.callUserCallback(version: BlueSTSDKFwVersion(self.mResponse))
            }
        }
        
    }
    
    ///call when the message is sent, start the timeout and reset the buffer string
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        mResponse = ""
        setTimeout()
    }
    
    private static func isCompeteLine(_ line:String)->Bool{
        if(line.count>2){
            return line.hasSuffix("\n\r") || line.hasSuffix("\r\n")
        }
        return false;
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) { }
 }
