//
//  SmartTagV2Iso15693Writer.swift
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
public class SmartTagV2Iso15693Writer {
    
    private typealias ReadCallback<T> = (Result<T,SmarTagIOError>) -> ()
    
    private let mTag2:SmarTag2IO
    
    public init(tag2IO:SmarTag2IO){
        mTag2 = tag2IO
    }
    
    private var memoryAddress: Int = 12
    
    public func writeConfiguration(_ conf:SmarTag2Data, onWriteComplete:@escaping (SmarTagIOError?)->Void){
        let virtualSensorNumberAndSampleTimeData = encodeVirtualSensorNumberAndSampleTime(conf)
        let timestampData = encodeTimestamp(conf)
        let vsConfigurationData = encodeVirtualSensorConfiguration(conf)
        
        self.mTag2.writeExtendedSingleBlock(startAddress: memoryAddress, data: virtualSensorNumberAndSampleTimeData) { configWriteError in
            guard configWriteError == nil else {
                onWriteComplete(configWriteError)
                return
            }
            
            self.memoryAddress += 1
            self.mTag2.writeExtendedSingleBlock(startAddress: self.memoryAddress, data: timestampData) { configWriteError in
                guard configWriteError == nil else {
                    onWriteComplete(configWriteError)
                    return
                }
                
                for i in 0..<vsConfigurationData.count {
                    self.memoryAddress += 1
                    self.mTag2.writeExtendedSingleBlock(startAddress: self.memoryAddress, data: vsConfigurationData[i]) { configWriteError in
                        guard configWriteError == nil else {
                            onWriteComplete(configWriteError)
                            return
                        }
                        if(i == vsConfigurationData.count-1){
                            onWriteComplete(nil)
                        }
                    }
                }
            }
        }
    }
    
    private func encodeVirtualSensorNumberAndSampleTime(_ configuration: SmarTag2Data) -> Data {
        var data = Data()
        data.append(configuration.header.virtualSensorInformation.rfu)
        data.append(configuration.header.virtualSensorInformation.numberVirtualSensor)
        data.append(configuration.header.virtualSensorInformation.sampleTime.toLEData)
        return data
    }
    
    private func encodeTimestamp(_ configuration: SmarTag2Data) -> Data {
        var data = Data()
        data.append(configuration.header.timestamp.timestamp.toLEData)
        return data
    }
    
    private func encodeVirtualSensorConfiguration(_ configuration: SmarTag2Data) -> [Data] {
        var vsConfigurationsData: [Data] = []
        
        guard let nfcCatalog = Nfc2CatalogService().currentCatalog() else { return vsConfigurationsData }
        let boardId = Int(configuration.header.baseInformation.boardID)
        let firmwareId = Int(configuration.header.baseInformation.firmwareID)
        guard let currentFw = findCurrentFwFromCatalog(nfcCatalog, devId: boardId, fwId: firmwareId) else { return vsConfigurationsData }
        
        configuration.virtualSensorConfiguration.forEach{ virtualSensorConfiguration in
            if(virtualSensorConfiguration.enabled){
                let data = createVirtualSensorData(virtualSensorConfiguration, nfcCatalog, currentFw)
                if(data != nil) {
                    vsConfigurationsData.append(data!)
                }
            }
        }
        return vsConfigurationsData
    }
    
    private func createVirtualSensorData(_ configuration: SmarTag2VirtualSensorConfiguration, _ nfcCatalog: Nfc2Catalog, _ currentFw: Nfc2Firmware) -> Data?{
        guard let vsCatalog = findVirtualSensorFwFromCatalog(currentFw, configuration.id) else { return nil}
        
        var bitLength = 0
        var pckDataTemp: UInt32
        
        // ID
        pckDataTemp = (UInt32(configuration.id) & UInt32(0x07))
        bitLength += vsCatalog.threshold.bitLengthID
        
        // MOD
        if(configuration.thUsageType != nil) {
            pckDataTemp = pckDataTemp | ((UInt32(configuration.thUsageType!) & calculateBitMask(UInt32(vsCatalog.threshold.bitLengthMod))) << (UInt32(bitLength)))
            bitLength += vsCatalog.threshold.bitLengthMod
        }
        
        // Threshold Min
        if(configuration.th1 != nil) {
            let min = calculateValueToPack(configuration.th1!, vsCatalog.threshold.offset, vsCatalog.threshold.scaleFactor)
            if(vsCatalog.threshold.thLow.bitLength != nil){
                pckDataTemp = pckDataTemp | ((UInt32(min) & UInt32(calculateBitMask(UInt32(vsCatalog.threshold.thLow.bitLength!)))) << (UInt32(bitLength)))
                bitLength += vsCatalog.threshold.thLow.bitLength!
            }
        }
        
        // Threshold Max
        if(configuration.th2 != nil) {
            let max = calculateValueToPack(configuration.th2!, vsCatalog.threshold.offset, vsCatalog.threshold.scaleFactor)
            if(vsCatalog.threshold.thHigh != nil) {
                if (vsCatalog.threshold.thHigh?.bitLength != nil) {
                    pckDataTemp = pckDataTemp | ((UInt32(max) & UInt32(calculateBitMask(UInt32(vsCatalog.threshold.thHigh!.bitLength!)))) << (UInt32(bitLength)))
                    bitLength += vsCatalog.threshold.thHigh!.bitLength!
                }
            }
        }
        
        var data = Data()
        data.append(pckDataTemp.toLEData)
        return data
        
    }
}

@available(iOS 14, *)
extension SmartTagV2Iso15693Writer {
    func calculateBitMask(_ length: UInt32) -> UInt32{
        return (1 << length) - 1
    }
    
    private func calculateValueToPack(_ v: Double, _ negativeOffset: Double?, _ scaleFactor: Double?) -> Int {
        // Example --> ((23.5f-10)/0.2).toInt()
        guard let negativeOffset = negativeOffset else { return Int(v) }
        guard let scaleFactor = scaleFactor else { return Int(v) }
        return Int((v-negativeOffset) / scaleFactor)
    }
    
    public func findCurrentFwFromCatalog(_ catalog: Nfc2Catalog, devId: Int, fwId: Int) -> Nfc2Firmware? {
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
    
    public func findVirtualSensorFwFromCatalog(_ currentFw: Nfc2Firmware, _ virtualSensorId: Int) -> VirtualSensor? {
        var virtualSensor: VirtualSensor? = nil
        currentFw.virtualSensors.forEach { vs in
            if(vs.id == virtualSensorId){
                virtualSensor = vs
            }
        }
        return virtualSensor
    }
}

fileprivate extension UInt16 {
    var toLEData:Data{
        var temp = self
        return Data(bytes: &temp,count: 2)
    }
}

fileprivate extension UInt32 {
    var toLEData:Data{
        var temp = self
        return Data(bytes: &temp,count: 4)
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
