//
//  NfcCatalogService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class Nfc2CatalogService {
    
    public typealias NfcCatalogCompletion = (Nfc2Catalog?) -> Void
    
    private static let catalogKey = "NfcCatalogKey"
    
    public init() {
        Self.self
    }
    
    public func currentCatalog() -> Nfc2Catalog? {
        let userDefaults = UserDefaults.standard
        
        let storedCatalog = userDefaults.object(forKey: Nfc2CatalogService.catalogKey)
        
        if let storedCatalog = storedCatalog as? Data {
            let decoder = JSONDecoder()
            if let loadedCatalog = try? decoder.decode(Nfc2Catalog.self, from: storedCatalog) {
                return loadedCatalog
            }
        }
        
        return nil
    }
    
    @discardableResult
    func storeCatalog(_ catalog: Nfc2Catalog?) -> Nfc2Catalog? {
        let userDefaults = UserDefaults.standard
        
        guard let catalog = catalog else {
            userDefaults.removeObject(forKey: Nfc2CatalogService.catalogKey)
            userDefaults.synchronize()
            return catalog
        }
    
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(catalog) {
            userDefaults.set(encoded, forKey: Nfc2CatalogService.catalogKey)
            userDefaults.synchronize()
            return catalog
        }
        
        return nil
    }
    
    /** Request Remote Firmware Catalog */
    public func requestNfcCatalog(onComplete: @escaping NfcCatalogCompletion) {
        URLSession.performNfcCatalogRequest(on: Object.self) { (result) in
            switch result {
            case .failure(let error):
                print(error)
                onComplete(nil)
            case .success(let response):
                self.storeCatalog(response)
                onComplete(response)
            }
        }
    }
    
    /** Get Firmware Details running on board (for Advertise)  */
    /*public func getFwDetailsNode(catalog: Catalog, device_id: Int, opt_byte_0: Int, opt_byte_1: Int) -> Firmware? {
        var fwDetail: Firmware?
        var bleFwId: Int
        
        var firmware: Firmware?
        
        if !(opt_byte_0 == 0x00){
            bleFwId = opt_byte_0
        }else{
            bleFwId = opt_byte_1+256
        }
        
        if(bleFwId<0){
            return nil
        }
        
        for fw in catalog.blueStSdkV2 {
            if(device_id == __uint8_t(fw.deviceId.dropFirst(2), radix: 16)! &&  __uint8_t(fw.bleVersionIdHex.dropFirst(2), radix: 16)! == bleFwId) {
                firmware = fw
            }
        }
        
        return firmware
        
    }*/
    
    /** Get Current Firmware Details running on board   */
    /*public func getCurrentFwDetailsNode(catalog: Catalog, device_id: Int, bleFwId: Int) -> Firmware? {
        var firmware: Firmware?
        
        for fw in catalog.blueStSdkV2 {
            if(device_id == __uint8_t(fw.deviceId.dropFirst(2), radix: 16)! &&  __uint8_t(fw.bleVersionIdHex.dropFirst(2), radix: 16)! == bleFwId) {
                firmware = fw
            }
        }
        
        return firmware
    }*/
    
    /** Get List of compatible firmwares with this particular board */
    /*public func getCompatibleFirmwaressNode(catalog: Catalog, device_id: Int, bleFwId: Int) -> [Firmware]? {
        var firmwares: [Firmware] = []
        
        for fw in catalog.blueStSdkV2 {
            if(device_id == __uint8_t(fw.deviceId.dropFirst(2), radix: 16)! &&  __uint8_t(fw.bleVersionIdHex.dropFirst(2), radix: 16)! != bleFwId) {
                firmwares.append(fw)
            }
        }
        
        return firmwares
    }*/
    
}

/** Used to retrieve Firmware Catalog */
protocol Requestable: Decodable {
    static var urlRequest: URLRequest { get }
}

struct Object: Requestable {
    static var urlRequest: URLRequest {
        #if DEBUG
            let url = URL(string: "https://raw.githubusercontent.com/SW-Platforms/appconfig/nfcsensor_2.0/nfcv2/catalog.json")! // DEBUG NFC Catalog
        #else
            let url = URL(string: "https://raw.githubusercontent.com/STMicroelectronics/appconfig/nfcsensor_2.0/nfcv2/catalog.json")! //RELEASED NFC Catalog
        #endif
        
        let request = URLRequest(url: url)
        return request
    }
}

extension URLSession {

    static func performNfcCatalogRequest<T: Requestable>(on decodable: T.Type, result: @escaping (Result<Nfc2Catalog, Error>) -> Void) {

        URLSession.shared.dataTask(with: decodable.urlRequest) { (data, response, error) in

            guard let data = data else { return }
            do {
                let object = try JSONDecoder().decode(Nfc2Catalog.self, from: data)
                result(.success(object))
            } catch {
                result(.failure(error))
            }

        }.resume()

    }

}

