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

class MultiNeuralNetworkConsole : NSObject {
    typealias CurrentAlgorithmCallback = (Int?)->()
    typealias AvailableAlgorithmsCallback = ([AvailableAlgorithm]?)->()
    
    private static let SET_ALGO_FORMAT = "setAIAlgo %d\n"
    private static let GET_AVAILABLE_ALGOS = "getAllAIAlgo\n"
    private static let GET_CURRENT_ALGO = "getAIAlgo\n"
    fileprivate static let COMMAND_TIMEOUT_S = TimeInterval(1)
    
    private let mConsole:BlueSTSDKDebug
    private var mCommandIsRunning:Bool = false
    
    init( console:BlueSTSDKDebug){
        mConsole = console
    }

    func enableAlgorithm(_ algo:AvailableAlgorithm, onComplete:@escaping ()->()){
        let cmd = String(format:MultiNeuralNetworkConsole.SET_ALGO_FORMAT,algo.index)
        mConsole.add(EnableAlgorithmListener(callback: onComplete))
        mConsole.writeMessage(cmd)
    }
    
    func getCurrentAlgorithmIndex( callback:@escaping CurrentAlgorithmCallback)->Bool{
        guard mCommandIsRunning == false else{
            return false
        }
        mCommandIsRunning = true
        mConsole.add(CurrentAlgorithmListener{ [weak self] index in
            self?.mCommandIsRunning = false
            callback(index)
        })
        mConsole.writeMessage(MultiNeuralNetworkConsole.GET_CURRENT_ALGO)
        return true
    }
    
    func getAvailableAlgorithms( callback:@escaping AvailableAlgorithmsCallback)->Bool{
        guard mCommandIsRunning == false else {
            return false
        }
        mCommandIsRunning = true
        mConsole.add(AvailableAlgorithmListener{ [weak self] algos in
            self?.mCommandIsRunning = false
            callback(algos)
        })
        mConsole.writeMessage(MultiNeuralNetworkConsole.GET_AVAILABLE_ALGOS)
        return true
    }
    
}

fileprivate class EnableAlgorithmListener : NSObject, BlueSTSDKDebugOutputDelegate {
    private let mCallback:()->()
    
    init(callback:@escaping ()->()){
        mCallback = callback
    }
    
    
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) { }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
       debug.remove(self)
        mCallback()
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {}
    
}

fileprivate class CurrentAlgorithmListener : NSObject, BlueSTSDKDebugOutputDelegate {
    private typealias Callback = MultiNeuralNetworkConsole.CurrentAlgorithmCallback

    private let mCallback:Callback
    private var mTimer:Timer?
    
    
    init(callback:@escaping MultiNeuralNetworkConsole.CurrentAlgorithmCallback){
        mCallback = callback
    }
    
    private func notifyResult(from console:BlueSTSDKDebug, index:Int?){
        mTimer?.invalidate()
        mTimer = nil
        console.remove(self)
        mCallback(index)
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        if(msg.last == "\n"){
            notifyResult(from:debug, index:Int(msg))
        }
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        mTimer = Timer(timeInterval: MultiNeuralNetworkConsole.COMMAND_TIMEOUT_S, repeats: false){ _ in
            self.notifyResult(from: debug, index: nil)
        }
        RunLoop.main.add(mTimer!, forMode: .common)
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {}
    
}

fileprivate class AvailableAlgorithmListener : NSObject, BlueSTSDKDebugOutputDelegate {
    private typealias Callback = MultiNeuralNetworkConsole.AvailableAlgorithmsCallback
    
    private let mCallback:Callback
    private var mTimer:Timer? = nil
    private var mResponseStr:String = ""

    init(callback:@escaping MultiNeuralNetworkConsole.AvailableAlgorithmsCallback){
        mCallback = callback
    }
    
    private func notifyResult(from console:BlueSTSDKDebug, algos:[AvailableAlgorithm]? ){
        mTimer?.invalidate()
        mTimer = nil
        console.remove(self)
        mCallback(algos)
    }
    
    func debug(_ console: BlueSTSDKDebug, didStdOutReceived msg: String) {
        mResponseStr.append(msg)
        if let algos = extractAvailableAlgos(str: mResponseStr){
            notifyResult(from: console, algos: algos)
        }
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        mTimer = Timer(timeInterval: MultiNeuralNetworkConsole.COMMAND_TIMEOUT_S, repeats: false){ _ in
           self.notifyResult(from: debug, algos: self.extractAvailableAlgos(str: self.mResponseStr))
        }
        RunLoop.main.add(mTimer!, forMode: .common)
        
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {}
    
    private func getAvailableAlgosResponse(from response:String) -> String?{
        print("Str:",response)
        if let matchRange = response.range(of: "((\\d+-.+,?)+)\\n", options: .regularExpression){
            //dropLast = remove the \n
            let matchStr = response[matchRange].dropLast()
            return String(matchStr)
        }else{
            return nil
        }
    }
    
    private func extractAvailableAlgos(str:String)->[AvailableAlgorithm]?{
        return getAvailableAlgosResponse(from: str)?.split(separator: ",").compactMap{ algoStr in
            let algoDetails = algoStr.split(separator: "-")
            if algoDetails.count == 2,
                let id = Int(algoDetails[0]){
                return AvailableAlgorithm(index: id, name: String(algoDetails[1]))
            }else{
                return nil
            }
        }
    }
    
}
