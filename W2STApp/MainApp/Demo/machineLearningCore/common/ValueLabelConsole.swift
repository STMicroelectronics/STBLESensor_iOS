/*
* Copyright (c) 2019  STMicroelectronics – All rights reserved
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

class ValueLabelConsole {
    
    private let mCommand:String
    private let mConsole:BlueSTSDKDebug
    private var isRunningCommand = false
    
    init(command:String,console:BlueSTSDKDebug) {
        mCommand = command
        mConsole = console
    }
    
    func loadLabel(onComplete:@escaping (ValueLabelMapper?)->()){
        guard isRunningCommand == false else{
            onComplete(nil)
            return
        }
        mConsole.add(LoadLabelValueMapperListener{[weak self] mapper in
            self?.isRunningCommand = false
            onComplete(mapper)
        })
        mConsole.writeMessage(mCommand)
    }
    
}

fileprivate class LoadLabelValueMapperListener : NSObject, BlueSTSDKDebugOutputDelegate {
    private typealias Callback = (ValueLabelMapper?)->()
    private static let COMMAND_TIMEOUT_S:TimeInterval = 1.0
    
    private let mCallback:Callback
    private var mTimer:Timer? = nil
    private var mResponseStr:String = ""

    init(callback:@escaping (ValueLabelMapper?)->()){
        mCallback = callback
    }
    
    private func notifyResult(from console:BlueSTSDKDebug, valueMapper:ValueLabelMapper? ){
        mTimer?.invalidate()
        mTimer = nil
        console.remove(self)
        mCallback(valueMapper)
    }
    
    func debug(_ console: BlueSTSDKDebug, didStdOutReceived msg: String) {
        mTimer?.invalidate()
        mResponseStr.append(msg)
        mTimer?.invalidate()
        if(mResponseStr.last == "\n"){
            mResponseStr.removeLast()
            if let mapper = buildRegisterMapperFromString(from:mResponseStr){
                // if the parser fail, clear the current buffer and wait a new line
                notifyResult(from: console, valueMapper: mapper)
            }else{
                mResponseStr=""
            }
        }
        startTimeoutTimer(console:console)
    }
        
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error:Error?) {
        startTimeoutTimer(console:debug)
    }
    
    private func startTimeoutTimer(console: BlueSTSDKDebug){
        mTimer?.invalidate()
        mTimer = nil
        mTimer = Timer(timeInterval: Self.COMMAND_TIMEOUT_S, repeats: false){ _ in
           self.notifyResult(from: console, valueMapper: self.buildRegisterMapperFromString(from: self.mResponseStr))
        }
        RunLoop.main.add(mTimer!, forMode: .common)
    }

    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {}
    
    private  static let REGISTER_INFO =  try! NSRegularExpression(pattern:"<(MLC|FSM_OUTS)(\\d+)(_SRC)?>(.*)")
    private  static let VALUE_INFO =  try! NSRegularExpression(pattern:"(\\d+)='(.*)'")
    
    private func buildRegisterMapperFromString(from response:String) -> ValueLabelMapper?{
        print("Str:",response)
        let registerData = response.split(separator: ";")
        let mapper = ValueLabelMapper()
        for data in registerData {
            let splitData = data.split(separator: ",")
            guard let (registerId, algoName) = extractRegisterInfo(registerInfo: String(splitData[0]))else{
                return nil
            }
            mapper.addRegisterName(register: registerId, label: algoName)
            for i in 1..<splitData.count{
                guard let (value,name) = extractValueInfo(valueInfo: String(splitData[i])) else{
                    return nil
                }
                mapper.addLabel(register: registerId, value: value, label: name)
            }
        }
        return mapper
        
    }
    
    private func extractRegisterInfo(registerInfo: String) -> (UInt8, String)? {
        let matches =  Self.REGISTER_INFO.matches(in: registerInfo, options: [], range: NSMakeRange(0, registerInfo.count))
        guard matches.count > 0 else{
            return nil
        }
        let match = matches[0]
        if let idRange = Range(match.range(at: 2), in: registerInfo),
           let nameRange = Range(match.range(at: 4), in: registerInfo),
           var id = UInt8(registerInfo[idRange]){
           let registerTypeRange = Range(match.range(at: 1), in: registerInfo)
            if(registerInfo[registerTypeRange!] == "FSM_OUTS"){
                id = id - 1
            }
            return (id,String(registerInfo[nameRange]))
        }else{
            return nil
        }
    }
    
    private func extractValueInfo(valueInfo: String) -> (UInt8, String)? {
        let matches =  Self.VALUE_INFO.matches(in: valueInfo, options: [], range: NSMakeRange(0, valueInfo.count))
        guard matches.count > 0 else{
            return nil
        }
        let match = matches[0]
        if let idRange = Range(match.range(at: 1), in: valueInfo),
           let nameRange = Range(match.range(at: 2), in: valueInfo),
           let id = UInt8(valueInfo[idRange]){
            return (id,String(valueInfo[nameRange]))
        }else{
            return nil
        }
    }

}
