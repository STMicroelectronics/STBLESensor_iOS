/*
* Copyright (c) 2019  STMicroelectronics – All rights reserved
* The STMicroelectronics corporate logo is a trademark of STMicroelectronics
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice, this list of conditions
* and the following disclaimer.
*
* - Redistributions in binary form must reproduce the above copyright notice, this list of
* conditions and the following disclaimer in the documentation and/or other materials provided
* with the distribution.
*
* - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
* STMicroelectronics company nor the names of its contributors may be used to endorse or
* promote products derived from this software without specific prior written permission.
*
* - All of the icons, pictures, logos and other images that are provided with the source code
* in a directory whose title begins with st_images may only be used for internal purposes and
* shall not be redistributed to any third party or modified in any way.
*
* - Any redistributions in binary form shall not include the capability to display any of the
* icons, pictures, logos and other images that are provided with the source code in a directory
* whose title begins with st_images.
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
import AssetTrackingDataModel

public class SmartTagIso15693Parser{
    
    private typealias ReadCallback<T> = (Result<T,SmarTagIOError>) -> ()
    
    private let mTag:SmarTagIO
    
    public init(tagIO:SmarTagIO){
        mTag = tagIO
    }
    
    public func readContent(onReadComplete:@escaping (Result<SmarTagData,SmarTagIOError>)->()){
        readMemoryLayout{ memoryLatyoutResult in
            manageErrorOr(memoryLatyoutResult, onError: onReadComplete){ memoryLayout in
                self.readVersion(baseOffset: memoryLayout.headerOffset) { versionResult in
                    manageErrorOr(versionResult, onError: onReadComplete){ version in
                        self.readConfiguration(baseOffset: memoryLayout.headerOffset){ confResult in
                            manageErrorOr(confResult, onError: onReadComplete){ configuration in
                                self.readSensorExtremes(baseOffset: memoryLayout.headerOffset, sensorConf: configuration){ extremeResult in
                                    manageErrorOr(extremeResult, onError: onReadComplete){ extreme in
                                        self.readSensorSample(layout: memoryLayout){ sensorResult in
                                            manageErrorOr(sensorResult, onError: onReadComplete) { samples in
                                                let data = SmarTagData(id: self.mTag.id,
                                                                       version: version,
                                                                       configuration: configuration,
                                                                       samples: samples,
                                                                       dataExtreme: extreme)
                                                print(data)
                                                onReadComplete(Result.success(data))
                                            }// comlete sample
                                        }//readSample
                                    }//complete extrem
                                }//read extreme
                            }// complete configuration
                        }//read configuration
                    }//complete version
                }//read version
            }//complete memory layout
        }//read memory layour
    }// readContent
    
    public func writeConfiguration(_ conf:Configuration, onWriteComplete:@escaping (SmarTagIOError?)->Void){
        readMemoryLayout{ memoryLatyoutResult in
            manageErrorOr(memoryLatyoutResult, onError: onWriteComplete){ memoryLayout in
                let data = SmarTagV1Parser.encodeConfiguration(conf)
                self.mTag.write(startAddress: SmartTagIso15693Parser.CONFIGURATION_BLOCK_RANGE.lowerBound + memoryLayout.headerOffset,data: data){ configWriteError in
                    guard configWriteError == nil else {
                        onWriteComplete(configWriteError)
                        return
                    }
                    if(conf.mode != .StoreNextSample){
                        self.resetSensorsData(memoryLayout: memoryLayout,onWriteComplete: onWriteComplete)
                    }else{
                        onWriteComplete(nil)
                    }
                }
                                
            }
        }
    }
    
    public func readSingleShotContent(onReadComplete:@escaping (Result<SensorDataSample,SmarTagIOError>)->()){
        readMemoryLayout{ memoryLatyoutResult in
            manageErrorOr(memoryLatyoutResult, onError: onReadComplete){ memoryLayout in
                self.readVersion(baseOffset: memoryLayout.headerOffset) { versionResult in
                    manageErrorOr(versionResult, onError: onReadComplete){ version in
                        self.readConfiguration(baseOffset: memoryLayout.headerOffset){ confResult in
                            manageErrorOr(confResult, onError: onReadComplete){ configuration in
                                self.waitReadyStatus(nTrial: 2, delay: 7.0, baseOffset: memoryLayout.headerOffset, onError: onReadComplete){
                                        self.readSensorExtremes(baseOffset: memoryLayout.headerOffset, sensorConf: configuration){ extremeResult in
                                            manageErrorOr(extremeResult, onError: onReadComplete){ extreme in
                                                
                                                let temperature = extreme.temperature?.minValue
                                                let pressure = extreme.pressure?.minValue
                                                let humidity = extreme.humidity?.minValue
                                                let accelerometer = extreme.acceleration?.maxValue
                                                let sample = SensorDataSample(date: Date(), temperature: temperature, humidity: humidity, pressure: pressure, acceleration: accelerometer)
                                                
                                                onReadComplete(.success(sample))
                                            }//complete extreme
                                        }//read extreme
                                    }//compelte tagStatus
                            }//compelte conf
                        }//read conf
                    }//compelte version
                }//read version
            }//complete layout
        }//read layout
    }//readSingleShotContent
    
    private func waitReadyStatus(nTrial:Int,delay:TimeInterval,baseOffset:Int, onError:@escaping (Result<SensorDataSample,SmarTagIOError>)->(),onReady:@escaping ()->()){
        //wait for the wake up
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.readTagStatus(baseOffset: baseOffset){ statusResult in
                manageErrorOr(statusResult, onError: onError){ tagStatus in
                    print(tagStatus)
                    if(tagStatus.singleShotResponseReady){
                        onReady()
                    }else{ //not ready
                        if(nTrial==0){ //max triad
                            onError(.failure(.tagResponseError))
                        }else{
                            self.waitReadyStatus(nTrial: nTrial-1, delay: delay, baseOffset: baseOffset, onError: onError, onReady: onReady)
                        }//if nTraial
                    }//if ready
                }//completeStatus
            }//readTagStatus
        }//dispatch
    }
    
    
    private func resetSensorsData(memoryLayout:SmarTagMemoryLayout,onWriteComplete:@escaping (SmarTagIOError?)->Void){
        let extremeData = SmarTagV1Parser.resetExtremeData()
        print((extremeData as NSData).debugDescription)
        print(SmartTagIso15693Parser.EXTREME_BLOCK_RANGE.lowerBound + memoryLayout.headerOffset)
        self.mTag.write(startAddress: SmartTagIso15693Parser.EXTREME_BLOCK_RANGE.lowerBound + memoryLayout.headerOffset, data: extremeData){ extremeDataError in
                guard extremeDataError == nil else {
                    onWriteComplete(extremeDataError)
                    return
                }
            let sampleInfo = SmarTagV1Parser.resetSensorSample(firstSampleBlock: UInt16(memoryLayout.firstDataSampleBlock))
            print((sampleInfo as NSData).description)
            self.mTag.write(startAddress: SmartTagIso15693Parser.SAMPLE_INFO_BLOCK + memoryLayout.headerOffset, data: sampleInfo, onComplete: onWriteComplete)
        }
    }
    
    private struct SmarTagMemoryLayout{
        let totalSize:Int
        let headerOffset:Int
        let firstDataSampleBlock:Int
        let lastDataSampleBlock:Int
        let numMaxSample:Int
        
        init(tagSize: TagSize, ndefHeaderOffset:Int){
            totalSize = Int(tagSize.rawValue)
            headerOffset = ndefHeaderOffset
            firstDataSampleBlock = FIRST_SAMPLE_POSITION + ndefHeaderOffset
            lastDataSampleBlock = Int(tagSize.rawValue) - 1
            numMaxSample = (lastDataSampleBlock - firstDataSampleBlock)/2
        }
    }
    
    private enum TagSize:UInt16{
        typealias RawValue = UInt16
        case kbit64 = 0x800
        case kbit4 = 0x80
    }
    
    private static func getTagSize(ccHeader: Data) -> TagSize{
        return ccHeader[2] == HAS_EXTENDED_CC_LENGTH ? .kbit64 : .kbit4
    }
    
    private func readMemoryLayout( onComplete: @escaping ReadCallback<SmarTagMemoryLayout>){
        mTag.read(address:SmartTagIso15693Parser.TAG_CC_ADDR){result in
            manageErrorOr(result,onError: onComplete){ data in
                let size = SmartTagIso15693Parser.getTagSize(ccHeader: data)
                self.findDataOffset(tagSize: size, startOffset: size == .kbit64 ? 3 : 2) { result in
                    manageErrorOr(result, onError: onComplete){ blockOffset in
                        let layout = SmarTagMemoryLayout(tagSize: size,ndefHeaderOffset: blockOffset)
                        onComplete(Result.success(layout))
                    }
                }
            }
        }
    }
    
    
    private func readVersion(baseOffset:Int, onComplete: @escaping ReadCallback<Version>){
        mTag.read(address: baseOffset + SmartTagIso15693Parser.FW_VERSION_BLOCK_OFFSET){ result in
            manageErrorOr(result, onError: onComplete){ versionData in
                if(versionData[0] != 1){
                    onComplete(Result.failure(SmarTagIOError.wrongProtocolVersion))
                }
                let version = SmarTagV1Parser.buildVersion(rawData:versionData)
                onComplete(Result.success(version))
            }
        }
    }
    
    private func readConfiguration( baseOffset:Int , onComplete: @escaping ReadCallback<Configuration>){
        let confStart = (SmartTagIso15693Parser.CONFIGURATION_BLOCK_RANGE.lowerBound + baseOffset)
        let confEnd = (SmartTagIso15693Parser.CONFIGURATION_BLOCK_RANGE.upperBound + baseOffset)
        mTag.read(range: confStart..<confEnd){ result in
            manageErrorOr(result, onError: onComplete){ confData in
                let config = SmarTagV1Parser.buildConfig(rawData:confData)
                onComplete(Result.success(config))
            }
            
        }
    }
    
    private func readTagStatus( baseOffset:Int , onComplete: @escaping ReadCallback<SmarTagStatus>){
        mTag.read(address: baseOffset+SmartTagIso15693Parser.SINGLE_SHOT_STATE){ result in
            manageErrorOr(result, onError: onComplete){ statusData in
                let status = SmarTagV1Parser.buildTagStatus(from: statusData)
                onComplete(Result.success(status))
            }
            
        }
    }
    
    private func readSensorExtremes(baseOffset:Int, sensorConf:Configuration, onComplete:@escaping ReadCallback<TagExtreme>){
        let confStart = (SmartTagIso15693Parser.EXTREME_BLOCK_RANGE.lowerBound + baseOffset)
        let confEnd = (SmartTagIso15693Parser.EXTREME_BLOCK_RANGE.upperBound + baseOffset)
        mTag.read(range: confStart..<confEnd){ result in
           manageErrorOr(result, onError: onComplete){ extreneData in
               let extremes = SmarTagV1Parser.buildTagExtreme(rawData:extreneData, configuration: sensorConf)
               onComplete(Result.success(extremes))
           }
           
       }
    }
    
    private func readSensorSample(layout:SmarTagMemoryLayout, onComplete: @escaping ReadCallback<[DataSample]>){
        let baseOffset = layout.headerOffset
        mTag.read(address: baseOffset + SmartTagIso15693Parser.SAMPLE_INFO_BLOCK){ blockInfoResult in
            manageErrorOr(blockInfoResult, onError: onComplete){ blockInfoData in
                let sampleInfo = SmarTagV1Parser.getAcquiredSampleInfo(rawData: blockInfoData)
                if(sampleInfo.nSample == 0){
                    onComplete(Result.success([]))
                    return
                }
                let sensorDataBlockStart = layout.firstDataSampleBlock
                let sensorDataBlockEnd = sensorDataBlockStart + Int(sampleInfo.nSample * 2) // each sample takes 8bytes -> 2 bloks
                self.mTag.read(range: sensorDataBlockStart..<sensorDataBlockEnd){ sensorsBlockResult in
                    manageErrorOr(sensorsBlockResult, onError: onComplete){ rawSensorData in
                        let lastSampleIndex = (Int(sampleInfo.nextSampleBlock) - layout.firstDataSampleBlock)/2 - 1
                        var firstSampleIndex = sampleInfo.nSample >= layout.numMaxSample ? lastSampleIndex + 1 : 0
                        var samples: [DataSample] = []
                        for _ in 0..<sampleInfo.nSample {
                            let sample = SmarTagV1Parser.getDataSample(from: rawSensorData , index: firstSampleIndex)
                            samples.append(sample)
                            firstSampleIndex = (firstSampleIndex + 1) % layout.numMaxSample
                        }
                        onComplete(Result.success(samples))
                    }
                }
            }
        }
    }
    
    private func findDataOffset(tagSize:TagSize, startOffset:Int, onCompelte:@escaping ReadCallback<Int>){
        
        let checkNextRecord = { (recordHeader:NDefRecordHeader) in
            let recordSize = Int(recordHeader.length) + Int(recordHeader.typeLength) + Int(recordHeader.payloadLength ) + Int(recordHeader.idLength)
            let newOffset = startOffset + recordSize/4
            if(recordHeader.isLastRecord || newOffset>tagSize.rawValue){
                onCompelte(Result.failure(.malformedNDef))
            }else{
                self.findDataOffset(tagSize: tagSize, startOffset: newOffset, onCompelte: onCompelte)
            }
        }
        
        mTag.readNDefRecordFromOffset(offset: startOffset){ result in
            manageErrorOr(result, onError: onCompelte){ ndefHeader in
                if( ndefHeader.type == SmartTagIso15693Parser.NDEF_EXTERNAL_TYPE){
                    let startByte = startOffset*4 + Int(ndefHeader.length)
                    self.mTag.readStringFromByteOffset(byteOffset: startByte, length:Int(ndefHeader.typeLength)){ tagType in
                        manageErrorOr(tagType, onError: onCompelte){ tagTypeStr in
                            if(tagTypeStr == SmartTagIso15693Parser.NDEF_SMARTAG_TYPE){
                                let payloadOffset = Int(ndefHeader.typeLength) + Int(ndefHeader.length) + Int(ndefHeader.idLength)
                                onCompelte(Result.success(startOffset+payloadOffset/4))
                            }else{
                                checkNextRecord(ndefHeader)
                            }
                        }//readString error
                    }//readString
                }else{
                    checkNextRecord(ndefHeader)
                }//if externalType
                
                
            }//readNdef error
        }//readNdef
    }
    
    private static let TAG_CC_ADDR = (0x00)
    private static let HAS_EXTENDED_CC_LENGTH = 0x00
    private static let NDEF_EXTERNAL_TYPE = UInt8(0x04)
    
    private static let FW_VERSION_BLOCK_OFFSET = (0x00)
    private static let CONFIGURATION_BLOCK_RANGE = 0x01..<0x05
    private static let SINGLE_SHOT_STATE = 0x05
    private static let EXTREME_BLOCK_RANGE = 0x06..<0x0F
    private static let SAMPLE_INFO_BLOCK = 0x0F
    private static let FIRST_SAMPLE_POSITION = 0x10

    private static let NDEF_SMARTAG_TYPE = "st.com:smartag"
}

fileprivate func manageErrorOr<InputT,OutpuT>(_ result:Result<InputT,SmarTagIOError>, onError:(Result<OutpuT,SmarTagIOError>) -> (), onSuccess:(InputT)->()){
    switch result {
    case .success(let data):
        onSuccess(data)
    case .failure(let error):
        onError(Result.failure(error))
    }
}

fileprivate func manageErrorOr<InputT>(_ result:Result<InputT,SmarTagIOError>, onError:(SmarTagIOError?) -> (), onSuccess:(InputT)->()){
    switch result {
    case .success(let data):
        onSuccess(data)
    case .failure(let error):
        onError(error)
    }
}
