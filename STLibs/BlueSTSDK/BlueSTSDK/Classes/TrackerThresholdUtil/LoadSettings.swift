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

import TrackerThresholdUtil

internal class LoadCommandListener: BlueSTSDKDebugOutputDelegate {
    private static let COMMAND_TIMEOUT_S = TimeInterval(1)
   
    
    private let mConsole: BlueSTSDKDebug
    private let mOnComplete:(BoardSamplingSettingsConsole.LoadConfigurationResult)->()
    private var nByteToRead = 0
    private var mBuffer: Data?
    private var mTimer: Timer?
    
    init(console:BlueSTSDKDebug, onComplete:@escaping (BoardSamplingSettingsConsole.LoadConfigurationResult)->()) {
        mConsole = console
        mOnComplete = onComplete
    }


    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        print("CloudTracker: received "+msg)
        
        let readByte = BlueSTSDKDebug.stringToData(msg)!
        if(mBuffer == nil) {
            nByteToRead = readByte.getBoardSamplingSettingsLength()
            mBuffer = Data(capacity: nByteToRead)
        }
        mBuffer?.append(readByte)

        if(isTransmissionCompleted()){
            removeTimeout()
            onTimeoutIsFired()
        } else {// message is splitted into shorter ones
            resetTimeout()
        }
    }

    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        print("CloudTracker: err "+msg)
    }

    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        print("CloudTracker: load send "+msg)
        resetTimeout()
        mBuffer = nil
        nByteToRead = 0
    }

    func resetTimeout() {
        removeTimeout()
        mTimer = Timer(timeInterval: Self.COMMAND_TIMEOUT_S, repeats: false) {_ in
            self.onTimeoutIsFired()
        }
        RunLoop.main.add(mTimer!, forMode: .common)
    }

    private func isTransmissionCompleted() -> Bool{
        return (mBuffer?.count ?? 0 >= nByteToRead) && (nByteToRead > 0)
    }
    
    func onTimeoutIsFired() {
        mConsole.remove(self)
        guard isTransmissionCompleted() else {
            DispatchQueue.main.async {
                self.mOnComplete(.failure(.trasmisionTimeout))
            }
            return
        }
        if let settings = mBuffer?.toBoardSamplingSettings(){
            DispatchQueue.main.async {
                self.mOnComplete(.success(settings))
            }
        }else{
            DispatchQueue.main.async {
                self.mOnComplete(.failure(.parsingError))
            }
        }
    }

    func removeTimeout() {
        mTimer?.invalidate()
        mTimer = nil
    }
}

