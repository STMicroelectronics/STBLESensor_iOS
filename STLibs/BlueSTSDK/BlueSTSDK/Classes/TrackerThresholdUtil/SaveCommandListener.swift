/*
* Copyright (c) 2020  STMicroelectronics – All rights reserved
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
import TrackerThresholdUtil

internal class SaveCommandListener: BlueSTSDKDebugOutputDelegate {
    private static let COMMAND_TIMEOUT_S: TimeInterval = 1
    
    private let mConsole:BlueSTSDKDebug
    private let mOnComplete:(BoardSamplingSettingsSaveError?)->()
    private let mLenghtMsg: Int
    
    private var mLenghtMsgSent = 0
    private var mTimer: Timer?

    init(console:BlueSTSDKDebug,messageSize:Int,onComplete: @escaping (BoardSamplingSettingsSaveError?) -> ()) {
        mConsole = console
        mOnComplete = onComplete
        mLenghtMsg = messageSize
    }

    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        NSLog("CloudTracker: received "+msg)
    }

    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        NSLog("CloudTracker: err "+msg)
    }

    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        NSLog("CloudTracker: store send size:\(msg.count) msg:"+msg+"")
        resetTimeout()
        mLenghtMsgSent+=msg.count
        if(mLenghtMsgSent>=mLenghtMsg) {
            removeTimeout()
            mConsole.remove(self)
            if(mLenghtMsgSent>mLenghtMsg) {
                DispatchQueue.main.async {
                    self.mOnComplete(.trasmisionTimeout)
                }
            }else{
                DispatchQueue.main.async {
                    self.mOnComplete(nil)
                }
            }//if
        }
    }

    private func resetTimeout() {
        removeTimeout()
        mTimer = Timer(timeInterval: Self.COMMAND_TIMEOUT_S, repeats: false) {_ in
            self.onTimeoutIsFired()
        }
        RunLoop.main.add(mTimer!, forMode: .common)
    }

    private func onTimeoutIsFired() {
        mConsole.remove(self)
        DispatchQueue.main.async {
            self.mOnComplete(.trasmisionTimeout)
        }
    }

    private func removeTimeout() {
        mTimer?.invalidate()
        mTimer = nil
    }
}
