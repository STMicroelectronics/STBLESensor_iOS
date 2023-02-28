//
//  SmarTagV2NDefParser.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class SmarTagV2NDefParser {
    private let rawData:Data
    private let id:Data?
    
    public init(identifier:Data, rawData:Data){
        self.rawData = rawData
        self.id = identifier.isEmpty ? nil : identifier
    }
    
    private static let SMARTAG2_BASE_INFORMATION_DATA_RANGE = 0..<4
    private static let SMARTAG2_VIRTUAL_SENSOR_INFORMATION = 4..<8
    private static let SMARTAG2_TIMESTAMP = 8..<12
    
    private static let FIRST_VIRTUAL_SENSOR_POSITION = 12
    
    private static func getSampleDataRange(startIndex:Int) -> Range<Int>{
        let end = startIndex + 4
        return startIndex..<end
    }
    
    /// Used for reading SmarTag2 Content
    public func readContent(_ nfcCatalog: Nfc2Catalog?, onReadComplete:@escaping (Result<SmarTag2Data,SmarTagIOError>)->()){
        guard rawData[0]==2 else {
            onReadComplete(.failure(.wrongProtocolVersion))
            return
        }
        
        guard nfcCatalog != nil else {
            onReadComplete(.failure(.unknown))
            return
        }
        
        let catalog = nfcCatalog!
        
        let tag2BaseInfo = SmarTagV2Parser.buildVersion(rawData: rawData.subdata(in: SmarTagV2NDefParser.SMARTAG2_BASE_INFORMATION_DATA_RANGE), id: id)
        let virtualSensorInfo = SmarTagV2Parser.buildVirtualSensorInformation(rawData: rawData.subdata(in: SmarTagV2NDefParser.SMARTAG2_VIRTUAL_SENSOR_INFORMATION))
        let timestampInfo = SmarTagV2Parser.buildTimestamp(rawData: rawData.subdata(in: SmarTagV2NDefParser.SMARTAG2_TIMESTAMP))

        var memoryStartingPointer = SmarTagV2NDefParser.FIRST_VIRTUAL_SENSOR_POSITION

        guard let currentFw = SmarTagV2Parser.retrieveCurrentFwFromCatalog(catalog, devId: Int(tag2BaseInfo.boardID), fwId: Int(tag2BaseInfo.firmwareID)) else {
            let data = SmarTag2Data(
                header: SmarTag2Header(
                    baseInformation: tag2BaseInfo,
                    virtualSensorInformation: virtualSensorInfo,
                    timestamp: timestampInfo
                ),
                virtualSensorConfiguration: [],
                extremes: [],
                sampleCounter: 0,
                lastSamplePointer: 0,
                dataSamples: []
            )
            return onReadComplete(.success(data))
        }
        
        Nfc2CurrentFirmware().storeCurrentFw(currentFw)
        
        /// Read VIRTUAL SENSOR Configuration
        var virtualSensors: [SmarTag2VirtualSensorConfiguration] = []
        for i in 0..<Int(virtualSensorInfo.numberVirtualSensor) {
            if !(i==0) {
                memoryStartingPointer = memoryStartingPointer + 4
            }
            let memoryRange = SmarTagV2NDefParser.getSampleDataRange(startIndex: memoryStartingPointer)
            let virtualSensorConfiguration = SmarTagV2Parser.buildVirtualSensorConfiguration(rawData: rawData.subdata(in: memoryRange), currentFw)
            if(virtualSensorConfiguration != nil){
                virtualSensors.append(virtualSensorConfiguration!)
            }
        }
        
        memoryStartingPointer += 4
        
        /// Read EXTREMES Data
        var extremes: [SmarTag2VirtualSensorExtreme] = []
        for i in 0..<Int(virtualSensorInfo.numberVirtualSensor) {
            if(i<=virtualSensors.count - 1){
                let currentVirtualSensor = virtualSensors[i]
                guard let virtualSensorCatalog = SmarTagV2Parser.retrieveVirtualSensorFromCatalog(currentFw, virtualSensorId: currentVirtualSensor.id) else { return}
                
                let virtualSensorExtremes = SmarTagV2Parser.buildExtremesData(rawData, memoryStartingPointer, currentFw, currentVirtualSensor, timestampInfo)
                if(virtualSensorExtremes != nil){
                    extremes.append(virtualSensorExtremes!)
                }
                if(virtualSensorExtremes?.min != nil || virtualSensorExtremes?.max != nil){
                    let wordRequired = calculateTotalBitLength(virtualSensorCatalog)
                    for i in 0..<wordRequired { memoryStartingPointer = memoryStartingPointer + 4 }
                }
            }
        }
        
        
        /// Read SampleCounter & Last Sample Pointer
        let sampleCounterMemoryRange = SmarTagV2NDefParser.getSampleDataRange(startIndex: memoryStartingPointer)
        let sampleCounter = SmarTagV2Parser.buildSampleCounter(rawData: rawData.subdata(in: sampleCounterMemoryRange))
        
        memoryStartingPointer += 4
        
        let lastSamplePointerMemoryRange = SmarTagV2NDefParser.getSampleDataRange(startIndex: memoryStartingPointer)
        let lastSamplePointer = SmarTagV2Parser.buildLastSamplePointer(rawData: rawData.subdata(in: lastSamplePointerMemoryRange))

        memoryStartingPointer += 4
        
        
        /// Read DATA SAMPLES Data
        var dataSamples: [SmarTag2DataSample] = []
        for i in 0..<sampleCounter {
            let memoryRange = SmarTagV2NDefParser.getSampleDataRange(startIndex: memoryStartingPointer)
            if(memoryRange.upperBound <= rawData.count){
                let id = SmarTagV2Parser.unpackVirtualSensorId(rawData.subdata(in: memoryRange))
                guard let virtualSensorCatalog = SmarTagV2Parser.retrieveVirtualSensorFromCatalog(currentFw, virtualSensorId: id) else { return}
                
                let virtualSensorDataSample = SmarTagV2Parser.buildSamplesData(rawData, memoryStartingPointer, currentFw, virtualSensorCatalog, timestampInfo)
                if(virtualSensorDataSample != nil){
                    dataSamples.append(virtualSensorDataSample!)
                }
                let wordRequired = calculateSampleTotalBitLength(virtualSensorCatalog)
                for i in 0..<wordRequired { memoryStartingPointer = memoryStartingPointer + 4 }
            }
        }
        
        let data = SmarTag2Data(
            header: SmarTag2Header(
                baseInformation: tag2BaseInfo,
                virtualSensorInformation: virtualSensorInfo,
                timestamp: timestampInfo
            ),
            virtualSensorConfiguration: virtualSensors,
            extremes: extremes,
            sampleCounter: sampleCounter,
            lastSamplePointer: lastSamplePointer,
            dataSamples: dataSamples
        )
        onReadComplete(.success(data))
    }
    
    /// Used for SmarTag2 provisioning
    public func readTag2BaseInfo(onReadComplete:@escaping (Result<SmarTag2BaseInformation,SmarTagIOError>)->()){
        guard rawData[0]==2 else {
            onReadComplete(.failure(.wrongProtocolVersion))
            return
        }
        let tag2BaseInfo = SmarTagV2Parser.buildVersion(rawData: rawData.subdata(in: SmarTagV2NDefParser.SMARTAG2_BASE_INFORMATION_DATA_RANGE), id: id)
        onReadComplete(.success(tag2BaseInfo))
    }
    
}


extension SmarTagV2NDefParser {
    func calculateTotalBitLength(_ vsCatalog: VirtualSensor) -> Int {
        var totalBit = 0
        var word = 1
        vsCatalog.maxMinFormat?.forEach{ format in
            totalBit += format.format.bitLength
            if(totalBit >= 32){
                word += 1
                totalBit -= 32
            }
        }
        return word
    }
    
    func calculateSampleTotalBitLength(_ vsCatalog: VirtualSensor) -> Int {
        var totalBit = 0
        var word = 1
        vsCatalog.sampleFormat?.forEach{ format in
            if(format.format != nil){
                totalBit += (format.format?.bitLength)!
                if(totalBit >= 32){
                    word += 1
                    totalBit -= 32
                }
            }
        }
        return word
    }
}
