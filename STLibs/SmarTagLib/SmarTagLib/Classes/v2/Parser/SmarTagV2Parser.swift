//
//  SmarTagV2Parser.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class SmarTagV2Parser{
    
    private static let PROTOCOL_VERSION = 0
    private static let PROTOCOL_REVISION = 1
    private static let BOARD_ID = 2
    private static let FIRMWARE_ID = 3
    
    private static let RFU = 0
    private static let NUMBER_VIRTUAL_SENSOR = 1
    private static let SAMPLE_TIME = 2
    
    private static let TIMESTAMP = 0
    
    private static let VIRTUALSENSOR_ID_MASK = UInt32(0x07)
    
    static func buildVersion(rawData:Data, id: Data?) -> SmarTag2BaseInformation{
        return SmarTag2BaseInformation(
            id: id,
            protocolVersion: rawData[SmarTagV2Parser.PROTOCOL_VERSION],
            protocolRevision: rawData[SmarTagV2Parser.PROTOCOL_REVISION],
            boardID: rawData[SmarTagV2Parser.BOARD_ID],
            firmwareID: rawData[SmarTagV2Parser.FIRMWARE_ID]
        )
    }
    
    static func buildVirtualSensorInformation(rawData:Data) -> SmarTag2VirtualSensorInformation{
        return SmarTag2VirtualSensorInformation(
            rfu: rawData[SmarTagV2Parser.RFU],
            numberVirtualSensor: rawData[SmarTagV2Parser.NUMBER_VIRTUAL_SENSOR],
            sampleTime: rawData.getLeUInt16(offset: SmarTagV2Parser.SAMPLE_TIME)
        )
    }
    
    static func buildTimestamp(rawData:Data) -> SmarTag2Timestamp{
        return SmarTag2Timestamp(timestamp: rawData.getLeUInt32(offset: SmarTagV2Parser.TIMESTAMP))
    }
    
    static func buildVirtualSensorConfiguration(rawData:Data, _ catalog: Nfc2Firmware) -> SmarTag2VirtualSensorConfiguration? {
        let intDataValue = rawData.getLeUInt32(offset: 0)
        let vsId = Int((intDataValue & VIRTUALSENSOR_ID_MASK))
        
        guard let virtualSensorCatalog = retrieveVirtualSensorFromCatalog(catalog, virtualSensorId: vsId) else {
            return nil
        }
        
        let idLength: UInt32 = UInt32(virtualSensorCatalog.threshold.bitLengthID)
        let modLength: UInt32 = UInt32(virtualSensorCatalog.threshold.bitLengthMod)
        let th1Length = virtualSensorCatalog.threshold.thLow.bitLength
        let th2Length = virtualSensorCatalog.threshold.thHigh?.bitLength
        
        let thUsageType = ((intDataValue >> idLength) & calculateBitMask(modLength))
        
        var th1: Double? = nil
        var th2: Double? = nil
        
        switch thUsageType {
        case 0:
            if(th1Length != nil && th2Length != nil){
                let thLow = ((intDataValue >> (idLength + modLength)) & calculateBitMask(UInt32(th1Length!)))
                th1 = thValueWithOffsetAndScaleFactor(Int(thLow), virtualSensorCatalog)
                let thHigh = ((intDataValue >> (idLength + modLength + UInt32(th1Length!))) & calculateBitMask(UInt32(th2Length!)))
                th2 = thValueWithOffsetAndScaleFactor(Int(thHigh), virtualSensorCatalog)
            }
        case 1:
            if(th1Length != nil && th2Length != nil) {
                let thLow = ((intDataValue >> (idLength + modLength)) & calculateBitMask(UInt32(th1Length!)))
                th1 = thValueWithOffsetAndScaleFactor(Int(thLow), virtualSensorCatalog)
                let thHigh = ((intDataValue >> (idLength + modLength + UInt32(th1Length!))) & calculateBitMask(UInt32(th2Length!)))
                th2 = thValueWithOffsetAndScaleFactor(Int(thHigh), virtualSensorCatalog)
            }
        case 2:
            if(th1Length != nil){
                let thLow = ((intDataValue >> (idLength + modLength)) & calculateBitMask(UInt32(th1Length!)))
                th1 = thValueWithOffsetAndScaleFactor(Int(thLow), virtualSensorCatalog)
                th2 = nil
            }
            if(th2Length != nil) {
                let thHigh = ((intDataValue >> (idLength + modLength)) & calculateBitMask(UInt32(th2Length!)))
                th1 = thValueWithOffsetAndScaleFactor(Int(thHigh), virtualSensorCatalog)
                th2 = nil
            }
        case 3:
            if(th1Length != nil){
                let thLow = ((intDataValue >> (idLength + modLength)) & calculateBitMask(UInt32(th1Length!)))
                th1 = thValueWithOffsetAndScaleFactor(Int(thLow), virtualSensorCatalog)
                th2 = nil
            }
            if(th2Length != nil) {
                let thHigh = ((intDataValue >> (idLength + modLength)) & calculateBitMask(UInt32(th2Length!)))
                th1 = thValueWithOffsetAndScaleFactor(Int(thHigh), virtualSensorCatalog)
                th2 = nil
            }
        default:
            th1 = nil
            th2 = nil
        }
        
        return SmarTag2VirtualSensorConfiguration(
            id: vsId,
            enabled: true,
            sensorName: virtualSensorCatalog.sensorName,
            thresholdName: virtualSensorCatalog.displayName,
            thUsageType: Int(thUsageType),
            th1: th1,
            th2: th2
        )
    }
    
    static func buildExtremesData(
        _ rawData: Data,
        _ currentPointer: Int,
        _ catalog: Nfc2Firmware,
        _ virtualSensor: SmarTag2VirtualSensorConfiguration,
        _ timestampInfo: SmarTag2Timestamp)
    -> SmarTag2VirtualSensorExtreme? {
        
        var addressToRead = currentPointer
        guard let virtualSensorCatalog = retrieveVirtualSensorFromCatalog(catalog, virtualSensorId: virtualSensor.id) else { return nil }
        
        var bitCounter = 0
        var previousLength: Int? = nil
        var ts: Date? = nil
        var min: Double? = nil
        var max: Double? = nil
        
        var currentExtremes = SmarTag2VirtualSensorExtreme(
            id: virtualSensor.id,
            type: virtualSensorCatalog.type,
            sensorName: virtualSensor.sensorName,
            thresholdName: virtualSensor.thresholdName,
            min: nil,
            max: nil
        )
        
        virtualSensorCatalog.maxMinFormat?.forEach{ extremeFormat in
            let bits = extremeFormat.format.bitLength
            if (bits <= 32) {
                if(extremeFormat.type.localizedCaseInsensitiveContains("time")){
                    let currentRaw = rawData.subdata(in: getSampleDataRange(startIndex: addressToRead))
                    ts = unpackExtremesTimeStamp(bitLength: bits, rawData: currentRaw, baseTagTimestamp: timestampInfo.timestamp)
                    previousLength = bits
                } else if(extremeFormat.type.localizedCaseInsensitiveContains("min")){
                    let currentRaw = rawData.subdata(in: getSampleDataRange(startIndex: addressToRead))
                    let negativeOffset = extremeFormat.format.offset
                    let scaleFactor = extremeFormat.format.scaleFactor
                    min = unpackVirtualSensorValue(bits, currentRaw, previousLength, virtualSensorCatalog)
                    previousLength = bits
                    let minExtreme = SmarTag2Extreme(timestamp: ts, value: min)
                    currentExtremes.min = minExtreme
                } else if(extremeFormat.type.localizedCaseInsensitiveContains("max")) {
                    let currentRaw = rawData.subdata(in: getSampleDataRange(startIndex: addressToRead))
                    let negativeOffset = extremeFormat.format.offset
                    let scaleFactor = extremeFormat.format.scaleFactor
                    max = unpackVirtualSensorValue(bits, currentRaw, previousLength, virtualSensorCatalog)
                    let maxExtreme = SmarTag2Extreme(timestamp: ts, value: max)
                    currentExtremes.max = maxExtreme
                }
            }
            
            bitCounter += bits
            
            if(bitCounter >= 32){
                addressToRead += 4
                bitCounter -= 32
                previousLength = nil
            }
        }
        
        return currentExtremes
    }
    
    static func buildSampleCounter(rawData:Data) -> Int {
        return Int(rawData.getLeUInt32(offset: 0))
    }
    
    static func buildLastSamplePointer(rawData:Data) -> Int {
        return Int(rawData.getLeUInt32(offset: 0))
    }
    
    static func buildSamplesData(
        _ rawData: Data,
        _ currentPointer: Int,
        _ catalog: Nfc2Firmware,
        _ virtualSensorCatalog: VirtualSensor,
        _ timestampInfo: SmarTag2Timestamp
    ) -> SmarTag2DataSample? {
        var addressToRead = currentPointer
       
        var bitCounter = 0
        var previousLength: Int? = nil
        var ts: Date? = nil
        var value: Double? = nil
        
        var idBitLength = 0
        
        virtualSensorCatalog.sampleFormat?.forEach{ sampleFormat in
            let bits = sampleFormat.format?.bitLength
            
            if (bits! <= 32) {
                if(sampleFormat.type.localizedCaseInsensitiveContains("id")){
                    bitCounter += sampleFormat.format?.bitLength ?? 0
                    idBitLength = sampleFormat.format?.bitLength ?? 0
                } else if(sampleFormat.type.localizedCaseInsensitiveContains("time")){
                    if(getSampleDataRange(startIndex: addressToRead).upperBound <= rawData.count){
                        let currentRaw = rawData.subdata(in: getSampleDataRange(startIndex: addressToRead))
                        ts = unpackDataSampleTimeStamp(bitLength: idBitLength, rawData: currentRaw, baseTagTimestamp: timestampInfo.timestamp)
                        previousLength = bits
                    }
                } else if(sampleFormat.type.localizedCaseInsensitiveContains("sample")) {
                    if(getSampleDataRange(startIndex: addressToRead).upperBound <= rawData.count){
                        let currentRaw = rawData.subdata(in: getSampleDataRange(startIndex: addressToRead))
                        value = unpackVirtualSensorValue(bits!, currentRaw, previousLength, virtualSensorCatalog)
                    }
                }
            }
            
            bitCounter += bits!

            if(bitCounter >= 32){
                addressToRead += 4
                bitCounter -= 32
                previousLength = nil
            }
        }
         
         return SmarTag2DataSample(
            id: virtualSensorCatalog.id,
            type: virtualSensorCatalog.type,
            date: ts,
            value: value
         )
    }
}

extension SmarTagV2Parser {
    static func calculateBitMask(_ length: UInt32) -> UInt32{
        return (1 << length) - 1
    }
    
    static func thValueWithOffsetAndScaleFactor(_ value: Int, _ vsc: VirtualSensor) -> Double{
        let negativeOffset = vsc.threshold.offset
        let scaleFactor =  vsc.threshold.scaleFactor
        guard (negativeOffset != nil) && (scaleFactor != nil) else {
            return Double(value)
        }
        return (Double(value) * scaleFactor!) + Double(negativeOffset!)
    }
    
    private static func getSampleDataRange(startIndex:Int) -> Range<Int>{
        let end = startIndex + 4
        return startIndex..<end
    }
}

extension SmarTagV2Parser {
    static func unpackVirtualSensorId(_ rawData: Data) -> Int {
        let intDataValue = rawData.getLeUInt32(offset: 0)
        return Int((intDataValue & VIRTUALSENSOR_ID_MASK))
    }
    
    static func unpackExtremesTimeStamp(bitLength: Int, rawData: Data, baseTagTimestamp: UInt32) -> Date {
        let rawDeltaTime = rawData.getLeUInt32(offset: 0)
        let shortDeltaTime = Int((rawDeltaTime & calculateBitMask(UInt32(bitLength))))
        let timeMillis = (shortDeltaTime * 60) + Int(baseTagTimestamp)
        return Date(timeIntervalSince1970: TimeInterval(timeMillis))
    }
    
    static func unpackDataSampleTimeStamp(bitLength: Int, rawData: Data, baseTagTimestamp: UInt32) -> Date {
        let rawDeltaTime = rawData.getLeUInt32(offset: 0)
        let deltaTime = Int(rawDeltaTime >> bitLength)
        let timeMillis = deltaTime + Int(baseTagTimestamp)
        return Date(timeIntervalSince1970: TimeInterval(timeMillis))
    }
    
    static func unpackVirtualSensorValue(_ bitLength: Int, _ rawData: Data, _ previousLength: Int?, _ vsc: VirtualSensor) -> Double {
        let intDataValue = rawData.getLeUInt32(offset: 0)
        
        if(previousLength == nil){
            let v = Int((intDataValue & calculateBitMask(UInt32(bitLength))))
            return thValueWithOffsetAndScaleFactor(v, vsc)
        } else {
            let v = Int(((intDataValue >> previousLength!) & calculateBitMask(UInt32(bitLength))))
            return thValueWithOffsetAndScaleFactor(v, vsc)
        }
    }
    
}

extension SmarTagV2Parser {
    static func retrieveVirtualSensorFromCatalog(_ catalog: Nfc2Firmware, virtualSensorId: Int) -> VirtualSensor? {
        var virtualSensorCatalog: VirtualSensor? = nil
        catalog.virtualSensors.forEach { vSc in
            if (vSc.id == virtualSensorId) {
                virtualSensorCatalog = vSc
            }
        }
        return virtualSensorCatalog
    }
    
    static func retrieveCurrentFwFromCatalog(_ catalog: Nfc2Catalog, devId: Int, fwId: Int) -> Nfc2Firmware? {
        var currentFw: Nfc2Firmware? = nil
        catalog.nfcV2firmwares.forEach { fw in
            let catalogDevId = UInt32(fw.nfcDevID.dropFirst(2), radix: 16) ?? 0
            let catalogFwId = UInt32(fw.nfcFwID.dropFirst(2), radix: 16) ?? 0
            if(catalogDevId == devId && catalogFwId == fwId){
                currentFw = fw
            }
        }
        return currentFw
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
