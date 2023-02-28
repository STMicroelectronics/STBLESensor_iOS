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
import BlueSTSDK

public class BlueNRGFwUpgradeConsole:BlueSTSDKFwUpgradeConsole{
    
    fileprivate static let DEFAULT_ACK_INTERVAL = UInt8(8)
    fileprivate static let SAFE_PACKAGE_LENGTH = UInt(16)
    
    fileprivate enum State{
        case empty
        case checkMemory(FwUpgradeParam)
        case setParameters(FwUpgradeSettings)
        case startUpload(FwUpgradeSettings)
        case upload(FwUpgradeSettings, UInt16)
        case end(URL)
        case error(URL,BlueSTSDKFwUpgradeError)
    };
    
    fileprivate struct FwUpgradeParam{
        let file:URL
        let baseAddress:UInt32?
        let packageSize:UInt
        
        static func buildSafeParamFrom(param:FwUpgradeParam)->FwUpgradeParam{
            return FwUpgradeParam(file: param.file,
                                             baseAddress: param.baseAddress,
                                             packageSize: BlueNRGFwUpgradeConsole.SAFE_PACKAGE_LENGTH)
        }
        
    }
    
    fileprivate struct FwUpgradeSettings{
        let file:URL
        let data:Data
        let ackInterval:UInt8
        let uploadSize:UInt32
        let baseAddress:UInt32
        let packageSize:UInt
    }
    
    fileprivate let mMemoryInfoFeature:BlueNRGMemoryInfoFeature!
    fileprivate let mSetSettingsFeature:BlueNRGFwUpgradeSettingsFeature!
    fileprivate let mDataTransferFeature:BlueNRGFwUpgradeDataTransferFeature!
    fileprivate let mAckFeature:BlueNRGFwUpgradeAckFeature!
    
    private var callback:BlueSTSDKFwUpgradeConsoleCallback? = nil
    fileprivate var mStartingParam: FwUpgradeParam!
    
    fileprivate var currentState : State {
        didSet{
            switch currentState {
            case .empty:
                return
            case .checkMemory(let param):
                mMemoryInfoFeature.add(CheckMemoryAddress(param:param, console: self))
                mMemoryInfoFeature.read()
                return
            case .setParameters(let settings):
                mSetSettingsFeature.add(SetUpgradeParameters(param: settings, console: self))
                mSetSettingsFeature.set(ackInternval: settings.ackInterval, imageSize: settings.uploadSize, baseAddress: settings.baseAddress)
                mSetSettingsFeature.read()
                return
            case .startUpload(let settings):
                mAckFeature.add(WriteDataAckListener(param: settings,console:self))
                mAckFeature.enableNotification()
                return
            case .upload(let settings, let requestSequence):
                upload(settings: settings, requestSequence: requestSequence)
                return
            case .end(let file):
                callback?.onLoadComplite(file: file)
                return
            case .error(let file, let error):
                callback?.onLoadError(file: file, error: error)
            }
        }
    }
    
    private func sendLastPackage(data: Data, sequence:UInt16, packageSize:Int){
        //prepare an array full of 0s for the padding
        var pckData = Data(count: packageSize)
        let fistByteToSend = Int(sequence)*packageSize
        let dataToSend = data.count - fistByteToSend
        //copy the values
        pckData[0..<dataToSend] = data[fistByteToSend...]
        _ = mDataTransferFeature.send(sequenceId: sequence, data: pckData, needAck: true)
        
    }
    
    private func upload( settings: FwUpgradeSettings, requestSequence:UInt16){
        let lastSequenceId = requestSequence+UInt16(settings.ackInterval-1)
        let intPackageSize = Int(settings.packageSize)
        callback?.onLoadProgres(file: settings.file, remainingBytes: UInt(settings.data.count-Int(requestSequence)*intPackageSize))
        for seqId in requestSequence...lastSequenceId{
            let fistByteIndex = Int(seqId)*intPackageSize
            let lastByteIndex = fistByteIndex + intPackageSize
            if(lastByteIndex>settings.data.count){
                sendLastPackage(data:settings.data, sequence:seqId,packageSize: intPackageSize)
                return
            }
            //else
            let data = settings.data[fistByteIndex..<lastByteIndex]
            _ = mDataTransferFeature.send(sequenceId: seqId, data: data, needAck: seqId == lastSequenceId)
        }
    }
    
    public init?(node:BlueSTSDKNode){
        if let memoryInfo = node.getFeatureOfType(BlueNRGMemoryInfoFeature.self) as? BlueNRGMemoryInfoFeature,
            let upgradeSettings = node.getFeatureOfType(BlueNRGFwUpgradeSettingsFeature.self) as? BlueNRGFwUpgradeSettingsFeature,
            let transferData = node.getFeatureOfType(BlueNRGFwUpgradeDataTransferFeature.self) as? BlueNRGFwUpgradeDataTransferFeature,
            let ackData = node.getFeatureOfType(BlueNRGFwUpgradeAckFeature.self) as? BlueNRGFwUpgradeAckFeature{
            mMemoryInfoFeature = memoryInfo
            mSetSettingsFeature = upgradeSettings
            mDataTransferFeature = transferData
            mAckFeature = ackData
            currentState = .empty
        }else{
            return nil
        }
    }
    
    public func loadFwFile(type: BlueSTSDKFwUpgradeType, file: URL, delegate: BlueSTSDKFwUpgradeConsoleCallback, address: UInt32?) -> Bool {
        switch currentState {
            case .empty:
                callback = delegate
                mStartingParam = FwUpgradeParam(file: file, baseAddress: address, packageSize: mDataTransferFeature.getMaxDataLength())
                currentState = .checkMemory(mStartingParam!)
                return true
            default:
                return false
        }
    }

}

fileprivate class CheckMemoryAddress : NSObject, BlueSTSDKFeatureDelegate {
    
    private let mParam:BlueNRGFwUpgradeConsole.FwUpgradeParam
    private let mConsole:BlueNRGFwUpgradeConsole
    
    init(param:BlueNRGFwUpgradeConsole.FwUpgradeParam, console:BlueNRGFwUpgradeConsole) {
        mParam = param
        mConsole = console
        super.init()
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        feature.remove(self)
        let lowerBoud = mParam.baseAddress ?? BlueNRGMemoryInfoFeature.getMemoryLowerBound(sample)
        let upperBound = BlueNRGMemoryInfoFeature.getMemroryUpperBound(sample)
        let availableSpace = upperBound-lowerBoud
        guard let dataToUpload = mParam.file.readFileContent() else {
            mConsole.currentState = .error(mParam.file, .invalidFwFile)
            return
        }
        guard lowerBoud % 512 == 0 else{
            mConsole.currentState = .error(mParam.file, .unsupportedOperation)
            return
        }
        let byteToUpload = dataToUpload.count.roudToBeMultipleOf(Int(mParam.packageSize))
        guard availableSpace >= byteToUpload else {
            mConsole.currentState = .error(mParam.file, .invalidFwFile)
            return
        }
        
        let param = BlueNRGFwUpgradeConsole.FwUpgradeSettings(file: mParam.file, data: dataToUpload, ackInterval: BlueNRGFwUpgradeConsole.DEFAULT_ACK_INTERVAL, uploadSize: UInt32(byteToUpload), baseAddress: lowerBoud, packageSize: mParam.packageSize)
        
        mConsole.currentState = .setParameters(param)
    }
    
}

fileprivate class SetUpgradeParameters : NSObject, BlueSTSDKFeatureDelegate{
    private static let MAX_READ_RETRY = 10;
    private static let READ_DELAY = TimeInterval(0.1) // 100ms
    
    private let mParam:BlueNRGFwUpgradeConsole.FwUpgradeSettings
    private let mConsole:BlueNRGFwUpgradeConsole
    
    init(param:BlueNRGFwUpgradeConsole.FwUpgradeSettings, console:BlueNRGFwUpgradeConsole) {
        mParam = param
        mConsole = console
        super.init()
    }

    private var nRetray = 0
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        feature.remove(self)
        let ackInterval = BlueNRGFwUpgradeSettingsFeature.getAckInterval(sample)
        let baseAddres = BlueNRGFwUpgradeSettingsFeature.getBaseAddress(sample)
        let imageSize = BlueNRGFwUpgradeSettingsFeature.getImageSize(sample)
        if(ackInterval != mParam.ackInterval || baseAddres != mParam.baseAddress || imageSize != mParam.uploadSize){
            nRetray = nRetray + 1
            if(nRetray>SetUpgradeParameters.MAX_READ_RETRY){
                mConsole.currentState = .error(mParam.file, .trasmissionError)
            }else{
                //parameters are different, read again after READ_DELAY
                DispatchQueue.main.asyncAfter(deadline: .now()+SetUpgradeParameters.READ_DELAY){
                    feature.read()
                }
            }
        }else{
            //parameters loaded
            mConsole.currentState = .startUpload(mParam)
        }
    }
}

fileprivate class WriteDataAckListener : NSObject , BlueSTSDKFeatureDelegate{
    
    private static let MAX_ERROR_RETRY = 4
    private static let WRITE_ACK_TIMEOUT_S = TimeInterval(4.0) //4s
    private let mParam:BlueNRGFwUpgradeConsole.FwUpgradeSettings
    private let mConsole:BlueNRGFwUpgradeConsole
    
    private var nWrongSequence = 0
    private var nWrongWrite1 = 0
    private var nWrongWrite2 = 0
    private var nWrongCrc = 0
    
    private let mTimerQueue:DispatchQueue
    private var mCurrentTimeOut:DispatchWorkItem? = nil
    
    init(param:BlueNRGFwUpgradeConsole.FwUpgradeSettings, console:BlueNRGFwUpgradeConsole){
        mTimerQueue = DispatchQueue(label: "BlueNRGWriteDataAck")
        mParam = param
        mConsole = console
    }
    
    private func setUpTimer(_ feature :BlueSTSDKFeature){
        mCurrentTimeOut?.cancel()
        mCurrentTimeOut = DispatchWorkItem{ [weak self, weak feature] in
            if let callback = self {
                feature?.remove(callback)
                callback.mConsole.currentState = .error(callback.mParam.file, .trasmissionError)
            }
        }
        mTimerQueue.asyncAfter(deadline: .now()+WriteDataAckListener.WRITE_ACK_TIMEOUT_S, execute: mCurrentTimeOut!)
    }
    
    private func removeTimer(){
        mCurrentTimeOut?.cancel()
    }
    
    private func resetErrorCount(){
        nWrongCrc = 0
        nWrongWrite2 = 0
        nWrongWrite1 = 0
        nWrongSequence = 0
    }
    
    private func abortTransmission(_ feature: BlueSTSDKFeature){
        self.removeTimer()
        feature.remove(self)
        feature.disableNotification()
    }
    
    private func manageError( _ feature: BlueSTSDKFeature, error:BlueNRGFwUpgradeAckFeature.Error, requestPacakge:UInt16){
        switch error {
        case .writeFail_1:
            nWrongWrite1 += 1
        case .writeFail_2:
            nWrongWrite2 += 1
        case .wrongCrc:
            nWrongCrc += 1
        case .wrongSequence:
            nWrongSequence += 1
        }
        
        if( nWrongCrc > WriteDataAckListener.MAX_ERROR_RETRY ||
            nWrongWrite1 > WriteDataAckListener.MAX_ERROR_RETRY ||
            nWrongWrite2 > WriteDataAckListener.MAX_ERROR_RETRY){
            abortTransmission(feature)
            mConsole.currentState = .error(mParam.file, .trasmissionError)
        }else if(nWrongSequence > WriteDataAckListener.MAX_ERROR_RETRY){
            if(requestPacakge == 0 ){ // the upload never starts
                abortTransmission(feature)
                //restart with the safe parameters
                mConsole.currentState = .checkMemory(BlueNRGFwUpgradeConsole.FwUpgradeParam.buildSafeParamFrom(param: mConsole.mStartingParam))
            }else{
                abortTransmission(feature)
                mConsole.currentState = .error(mParam.file, .trasmissionError)
            }
        }else{
            setUpTimer(feature)
            mConsole.currentState = .upload(mParam, requestPacakge)
        }
    }
    
    private func isUploadCompleted(_ nextSequence:UInt16) -> Bool{
        return Int(nextSequence)*Int(mParam.packageSize) >= mParam.data.count
    }
    
    private func manageSuccess(_ feature: BlueSTSDKFeature, requestPacakge:UInt16){
        if(isUploadCompleted(requestPacakge)){
            feature.remove(self)
            removeTimer()
            mConsole.currentState = .end(mParam.file)
        }else{
            setUpTimer(feature)
            mConsole.currentState = .upload(mParam,requestPacakge)
        }
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let nextSequence = BlueNRGFwUpgradeAckFeature.getExpectedSequence(sample)
        let error = BlueNRGFwUpgradeAckFeature.getError(sample)
        
        if let errorCode = error {
            manageError(feature, error: errorCode, requestPacakge: nextSequence)
        }else{
            resetErrorCount()
            manageSuccess(feature, requestPacakge: nextSequence)
        }        
    }
}


fileprivate extension URL{
    func readFileContent()->Data?{
        let fileHandler = try? FileHandle(forReadingFrom: self)
        let data = fileHandler?.readDataToEndOfFile()
        fileHandler?.closeFile()
        return data
    }
}

fileprivate extension Int{
    func roudToBeMultipleOf(_ multiple:Int)->Int{
        let ( _, renainder ) = self.quotientAndRemainder(dividingBy: multiple)
        if(renainder == 0){
            return self
        }else{
            return self + multiple - renainder
        }
        
    }
}

