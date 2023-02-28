//
//  SmartTagV2Iso15693Parser.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

@available(iOS 14, *)
public class SmartTagV2Iso15693Parser {
    
    private typealias ReadCallback<T> = (Result<T,SmarTagIOError>) -> ()
    
    private let mTag2:SmarTag2IO
    
    public init(tag2IO:SmarTag2IO){
        mTag2 = tag2IO
    }

    public func readSingleShotContent(catalog: Nfc2Catalog, onReadComplete:@escaping (Result<SmarTag2Data,SmarTagIOError>)->()){
        readMemoryLayout{ memoryLatyoutResult in
            self.manageErrorOr(memoryLatyoutResult, onError: onReadComplete){ memoryLayout in
                self.waitReadyStatus(nTrial: 2, delay: 7.0, baseOffset: memoryLayout.headerOffset, onError: onReadComplete){
                    self.mTag2.read(range: (memoryLayout.headerOffset..<SmartTagV2Iso15693Parser.MAX_BLOCK_TO_READ_POSITION)){ rawDataResult in
                        self.manageErrorOr(rawDataResult, onError: onReadComplete){ rawData in
                            let parser = SmarTagV2NDefParser(identifier: Data("singleShotID".utf8), rawData: rawData)
                            parser.readContent(catalog) { [weak self] smarTag2DataResult in
                                self?.manageErrorOr(smarTag2DataResult, onError: onReadComplete){ smarTag2Data in
                                    onReadComplete(.success(smarTag2Data))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func readMemoryLayout(onComplete: @escaping ReadCallback<SmarTagMemoryLayout>){
        mTag2.read(address:SmartTagV2Iso15693Parser.TAG_CC_ADDR){result in
            self.manageErrorOr(result,onError: onComplete){ data in
                let size = SmartTagV2Iso15693Parser.getTagSize(ccHeader: data)
                self.findDataOffset(tagSize: size, startOffset: size == .kbit64 ? 3 : 2) { result in
                    self.manageErrorOr(result, onError: onComplete){ blockOffset in
                        let layout = SmarTagMemoryLayout(tagSize: size,ndefHeaderOffset: blockOffset)
                        onComplete(Result.success(layout))
                    }
                }
            }
        }
    }
    
    private func waitReadyStatus(nTrial:Int,delay:TimeInterval,baseOffset:Int, onError:@escaping (Result<SmarTag2Data,SmarTagIOError>)->(),onReady:@escaping ()->()){
        //wait for the wake up
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.readSingleShotIsReadyField(baseOffset: baseOffset){ isReadyResult in
                self.manageErrorOr(isReadyResult, onError: onError){ isReady in
                    print("SINGLE SHOT STATUS: \(isReady.rfu)")
                    if(isReady.rfu == 1){
                        onReady()
                    }else{ //not ready
                        if(nTrial==0){ //max triad
                            onError(.failure(.tagResponseError))
                        }else{
                            self.waitReadyStatus(nTrial: nTrial-1, delay: delay, baseOffset: baseOffset, onError: onError, onReady: onReady)
                        }
                    }
                }
            }
        }
    }
    
    private func readSingleShotIsReadyField(baseOffset:Int, onComplete: @escaping ReadCallback<SmarTag2VirtualSensorInformation>){
        mTag2.read(address: baseOffset + SmartTagV2Iso15693Parser.SINGLE_SHOT_BLOCK_OFFSET){ result in
            self.manageErrorOr(result, onError: onComplete){ virtualSensorInformation in
                let tag2VirtualSensorInfo = SmarTag2VirtualSensorInformation(rfu: virtualSensorInformation[0], numberVirtualSensor: virtualSensorInformation[1], sampleTime: virtualSensorInformation.getLeUInt16(offset: SmartTagV2Iso15693Parser.SAMPLE_TIME))
                onComplete(Result.success(tag2VirtualSensorInfo))
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
        
        readNDefRecordFromOffset(offset: startOffset){ result in
            self.manageErrorOr(result, onError: onCompelte){ ndefHeader in
                if( ndefHeader.type == SmartTagV2Iso15693Parser.NDEF_EXTERNAL_TYPE){
                    let startByte = startOffset*4 + Int(ndefHeader.length)
                    self.readStringFromByteOffset(byteOffset: startByte, length:Int(ndefHeader.typeLength)){ tagType in
                        self.manageErrorOr(tagType, onError: onCompelte){ tagTypeStr in
                            if(tagTypeStr == SmartTagV2Iso15693Parser.NDEF_SMARTAG_TYPE){
                                let payloadOffset = Int(ndefHeader.typeLength) + Int(ndefHeader.length) + Int(ndefHeader.idLength)
                                onCompelte(Result.success(startOffset+payloadOffset/4))
                            }else{
                                checkNextRecord(ndefHeader)
                            }
                        }
                    }
                }else{
                    checkNextRecord(ndefHeader)
                }
            }
        }
    }
    
    func readNDefRecordFromOffset( offset:Int, onComplete: @escaping (Result<NDefRecordHeader,SmarTagIOError>)->()){
        mTag2.read(range: offset..<offset+2){ result in
            print("readNDefRecordFromOffset",result)
            switch(result){
            case .failure(let error):
                onComplete(Result.failure(error))
                return
            case .success( let rawHeader):
                let payloadLengthSize = rawHeader[0].isShortRecord ? 1 : 4
                let payloadLength = rawHeader[0].isShortRecord ? UInt32(rawHeader[2]) : rawHeader[2..<6].toBEUInt32
                let idLength = rawHeader[0].hasIdLength ? rawHeader[2 + payloadLengthSize] : 0
                let ndefHeader = NDefRecordHeader(tnf: rawHeader[0],
                                                  idLength: idLength,
                                                  typeLength: rawHeader[1],
                                                  payloadLength: payloadLength)
                onComplete(Result.success(ndefHeader))
            }
        }
    }

    func readStringFromByteOffset(byteOffset:Int, length:Int, onComplete: @escaping (Result<String,SmarTagIOError>)->()){
        let (startBlock, blockOffset) = byteOffset.quotientAndRemainder(dividingBy: 4)
        let endBlock = startBlock + (length+blockOffset+4)/4 // +4 to have the floor
        mTag2.read(range: startBlock..<endBlock){  result in
            switch(result){
            case .failure(let error):
                onComplete(Result.failure(error))
                return
            case .success( let rawData):
                let stringData = rawData[blockOffset..<blockOffset+length]
                onComplete(Result.success(String(bytes: stringData, encoding: .ascii)!))
            }
        }
    }

    fileprivate func manageErrorOr<InputT,OutpuT>(_ result:Result<InputT,SmarTagIOError>, onError:(Result<OutpuT,SmarTagIOError>) -> (), onSuccess:(InputT)->()){
        switch result {
        case .success(let data):
            onSuccess(data)
        case .failure(let error):
            onError(Result.failure(error))
        }
    }
    
    private static let TAG_CC_ADDR = (0x00)
    private static let HAS_EXTENDED_CC_LENGTH = 0x00
    private static let NDEF_EXTERNAL_TYPE = UInt8(0x04)
    
    private static let SINGLE_SHOT_BLOCK_OFFSET = (0x01)
    private static let SAMPLE_TIME = 2
    private static let FIRST_VIRTUAL_SENSOR_POSITION = 12
    private static let MAX_BLOCK_TO_READ_POSITION = 500
    
    private static let FIRST_SAMPLE_POSITION = 0x10

    private static let NDEF_SMARTAG_TYPE = "st.com:smartag"
    
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
}

fileprivate extension Data{
    
    func getLeUInt16(offset:Index)->UInt16{
        var value = UInt16(0)
        value = UInt16(self[self.startIndex+offset]) | UInt16(self[self.startIndex+offset+1])<<8
        return value
    }
        
    func getLeUInt32(offset:Index)->UInt32{
        return  UInt32(self[self.startIndex+offset])         | (UInt32(self[self.startIndex+offset+1])<<8) |
                (UInt32(self[self.startIndex+offset+2])<<16) | (UInt32(self[self.startIndex+offset+3])<<24)
    }
}
