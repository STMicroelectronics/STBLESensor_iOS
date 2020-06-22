/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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

protocol BlueMSConsoleCommandCallback {

    func onCommandResponds(_ response:String);
    func onCommandError();

}

class BlueMSConsoleCommand{

    private let mConsole:BlueSTSDKDebug;
    private let mCommandTimeout:TimeInterval;

    public init(_ console:BlueSTSDKDebug,_ timeout:TimeInterval){
        mConsole = console;
        mCommandTimeout = timeout;
    }

    func exec(_ command:String,_ callback:BlueMSConsoleCommandCallback!){
        exec(command,
                onCommandResponds: callback.onCommandResponds,
                onCommandError: callback.onCommandError);
    }


    func exec(_ command:String,onCommandResponds:@escaping (String)->(),onCommandError: @escaping ()->() ){
        mConsole.add(ConsoleListener(
                timeOut: mCommandTimeout,
                onCommandResponds: onCommandResponds,
                onCommandError:onCommandError));
        mConsole.writeMessage(command);

    }

    private class ConsoleListener : NSObject,BlueSTSDKDebugOutputDelegate{

        private let mOnCommandResponse:(String)->();
        private let mOnCommandError:()->();
        private var mRensponseBuffer = "";
        private var mFirstInput=true;
        private let mTimerTimeout:TimeInterval;
        private var mTimer:Timer?;

        init(timeOut:TimeInterval, onCommandResponds:@escaping (String)->(),
             onCommandError:@escaping ()->()){
            mTimerTimeout = timeOut;
            mOnCommandResponse=onCommandResponds;
            mOnCommandError=onCommandError;

        }

        func debug(_ console:BlueSTSDKDebug, didStdOutReceived msg:String){
            mRensponseBuffer.append(msg);
        }

        func debug(_ console:BlueSTSDKDebug, didStdInSend msg:String, error:Error?){
            guard error == nil else{
                console.remove(self);
                mOnCommandError();
                return;
            }
            if(mFirstInput){
                mFirstInput=false;
                //since the callback is done in a temp thread, we schedule the timer in the main thread
                DispatchQueue.main.sync {
                    //TODO remove NSObject extension when the app will target ios10, and use the block version instad of
                    // the selector
                    //mTimer = Timer(timeInterval: mTimerTimeout, repeats: false) { timer in  self.onTimeoutFire()}
                    mTimer = Timer.scheduledTimer(timeInterval: mTimerTimeout, target: self, selector: #selector(onTimeoutFire),
                            userInfo: console, repeats: false)
                }
            }
        }

        @objc public func onTimeoutFire(firedTimer:Timer){
            let console = firedTimer.userInfo as! BlueSTSDKDebug;
            console.remove(self);
            if(mRensponseBuffer.isEmpty) {
                mOnCommandError();
            }else{
                mOnCommandResponse(mRensponseBuffer);
            }
        }

        func debug(_ console:BlueSTSDKDebug, didStdErrReceived msg:String){
            //not used
        }
    }

}
