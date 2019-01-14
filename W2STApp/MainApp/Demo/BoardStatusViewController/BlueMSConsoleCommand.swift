//
// Created by Giovanni Visentini on 09/05/2017.
// Copyright (c) 2017 STMicroelectronics. All rights reserved.
//

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
