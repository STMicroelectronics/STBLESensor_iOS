//
//  GenericDataResponse.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import AssetTrackingDataModel
import TrackerThresholdUtil
import SmarTagLib

struct GenericDataResponse: Decodable {
    let values: [GenericDataResponseItem]
}

public enum GenericDataResponseItem {
    case generic(GenericSample)
    case location(Location)
    
    var generic: GenericSample? {
        guard case .generic(let data) = self else { return nil }
        return data
    }
    
    var location: Location? {
        guard case .location(let data) = self else { return nil }
        return data
    }
}

extension GenericDataResponseItem: Decodable {
    enum Domains: String {
        case gnss
    }
    
    enum ValueCodingKeys: String, CodingKey {
        case ts
        case t
        case v
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ValueCodingKeys.self)
        let date = try container.decode(Double.self, forKey: .ts).date
        let domainRaw = try container.decode(String.self, forKey: .t)
        
        let domain = Domains(rawValue: domainRaw)
        
        if(domain == .gnss) {
            let value = try container.decode(Vgeolocation.self, forKey: .v)
            self = Self.locationFrom(date: date, measure: "gnss", value: value)
        }else{
            let value = try container.decode(Float.self, forKey: .v)
            self = Self.genericFrom(date: date, measure: domainRaw, value: value)
        }
       
    }
    
    private static func genericFrom(date: Date, measure: String, value: Float) -> GenericDataResponseItem {
        let sample: GenericSample
        
        /// TODO: Hardcoded BOARD ID & FIRMWARE ID ... Remove when DataSample return this pair infos
        let nfcCatalog = Nfc2CatalogService().currentCatalog()
        let currentFw = findCurrentFwFromCatalog(nfcCatalog, devId: Int(0x01), fwId: Int(0x01))
        guard let currentFw = currentFw else { return .generic(GenericSample(id: 0, type: measure, date: date, value: Double(value))) }
        let currentThId = findCurrentThresholdId(currentFw, measure: measure)
        sample = GenericSample(id: currentThId, type: measure, date: date, value: Double(value))
        return .generic(sample)
    }
    
    private static func locationFrom(date: Date, measure: String, value: Vgeolocation) -> GenericDataResponseItem {
        let sample: Location
        
        sample = Location(latitude: Double(value.lat), longitude: Double(value.lon), altitude: Double(value.ele))
        
        return .location(sample)
    }
    
    public static func findCurrentFwFromCatalog(_ catalog: Nfc2Catalog?, devId: Int, fwId: Int) -> Nfc2Firmware? {
        var currentFw: Nfc2Firmware? = nil
        guard let catalog = catalog else { return nil }
        catalog.nfcV2firmwares.forEach { fw in
            let catalogDevId = UInt32(fw.nfcDevID.dropFirst(2), radix: 16) ?? 0
            let catalogFwId = UInt32(fw.nfcFwID.dropFirst(2), radix: 16) ?? 0
            if(catalogDevId == devId && catalogFwId == fwId){
                currentFw = fw
            }
        }
        return currentFw
    }
    
    public static func findCurrentThresholdId(_ currentFw: Nfc2Firmware, measure: String) -> Int {
        var id = 0
        currentFw.virtualSensors.forEach { th in
            if(th.type == measure){
                id = th.id
            }
        }
         return id
        
    }
}
