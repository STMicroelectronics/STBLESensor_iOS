//
//  AwsDeviceManager.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 30/08/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import TrackerThresholdUtil
import AssetTrackingDataModel

private extension AssetTrackingDevice.DeviceType {
    var toCloudStr:String?{
        switch self {
        case .ASTRA:
            return "steval-astra1b:mcu:fp-atr-astra1:1"
        case .NFCTAG2:
            return "smartag2:mcu:fp-sns-smartag2:1"
        case .NFCTAG1:
            return "smartag1:mcu:fp-sns-smartag1:1"
        case .SENSORTILEBOX:
            return "sensortile-box:mcu:fp-atr-ble1:1"
        case .LORATTN:
            return "Lora_ttn"
        case .WIFI:
            return "wifi"
        case .BLE:
            return "ble"
        case .UNKNOWN:
            return nil
        }
    }
}

class AwsDeviceManager : DeviceManager {
    
    typealias Upload = (samples: JSON, type: UploadType)
    
    enum UploadType: String {
        case telemetry
        case events
    }
    
    private static let uploadChunkSize = 200
    
    private let api: RestAPI
    private var credential: AuthzCredential?
    
    init(credential: AuthzCredential?) {
        self.credential = credential
        self.api = RestAPI()
    }
    
    func listDevices(onComplete: @escaping (DeviceListOperationResult) -> Void) {
        api.get(path: RestAPI.Paths.devices, credential: credential) { result in
            switch(result) {
            case .success(let response):
                guard response.statusCode == 200,
                      let data = response.data,
                      let devices = try? JSONDecoder().decode([AssetTrackingDevice].self, from: data) else {
                    return onComplete(.failure(.deviceNotFound))
                }
                
                onComplete(.success(devices))
            case .failure(let error):
                onComplete(.failure(.ioError))
            }
        }
    }
    
    func addDevice(device: AssetTrackingDevice, name: String, certificate: String?, macaddress: String?, deviceprofile: String?, devEui: String?, onComplete: @escaping (DeviceAddOperationResult) -> Void) {
        var json = JSON()
 
        json["device_id"].stringValue = device.id
        json["label"].stringValue = name
        
        if let typeStr = device.deviceType.toCloudStr {
            json["device_type"].stringValue = typeStr
            if !(deviceprofile==nil){
                json["device_profile"].stringValue = deviceprofile!
            }
            var tech = JSON()
            tech["technology"].stringValue = typeStr
            if !(macaddress==nil){
                tech["device_mac"].stringValue = macaddress!
                if !(devEui==nil){
                    tech["device_eui"].stringValue = devEui!
                }
            }
            json[typeStr] = tech
            
            if let certificate = certificate {
                tech["certificate"].stringValue = certificate
            }
        }
        
        guard let data = try? json.rawData() else {
            onComplete(.failure(.ioError))
            return
        }
        
        api.post(path: RestAPI.Paths.devicesAdd, data: data, credential: credential) { result in
            switch(result) {
            case .success(let response):
                guard 200 ..< 300 ~= response.statusCode,
                      let data = response.data,
                      let cert = String(data: data, encoding: .utf8) else { return onComplete(.failure(.deviceAlreadyRegistered)) }
                var updatedDevice = device
                updatedDevice.certificate = cert
                onComplete(.success(updatedDevice))
            case .failure(let error):
                print(error)
                onComplete(.failure(.ioError))
            }
        }
    }
    
    func apiKey(completion: @escaping (DeviceApiKeyOperationResult) -> Void) {
        getApiKey { [weak self] result in
            switch result {
            case .success(let apiKey):
                completion(.success(apiKey))
            case .failure(let error):
                guard error == .missingApiKey else { return completion(.failure(.ioError)) }
                self?.postApiKey { result in
                    guard case .success = result else { return completion(.failure(.ioError)) }
                    self?.getApiKey(completion: completion)
                }
            }
        }
    }
    
    func deviceProfiles(completion: @escaping (DeviceProfilesOperationResult) -> Void) {
        getDeviceProfiles{ [weak self] result in
            switch result {
            case .success(let deviceProfiles):
                completion(.success(deviceProfiles))
            case .failure(let error):
                guard error == .missingDeviceProfiles else { return completion(.failure(.ioError)) }
                self?.postApiKey { result in
                    guard case .success = result else { return completion(.failure(.ioError)) }
                    self?.getDeviceProfiles(completion: completion)
                }
            }
        }
    }
    
    func defaultDeviceProfile(completion: @escaping (DeviceProfileOperationResult) -> Void) {
        getDefaultDeviceProfile{ [weak self] result in
            switch result {
            case .success(let deviceProfile):
                completion(.success(deviceProfile))
            case .failure(let error):
                guard error == .missingDeviceProfiles else { return completion(.failure(.ioError)) }
                self?.postApiKey { result in
                    guard case .success = result else { return completion(.failure(.ioError)) }
                    self?.getDefaultDeviceProfile(completion: completion)
                }
            }
        }
    }
    
    func removeDevice(id: String,onComplete: @escaping (DeviceOperationResult)->()) {
        api.delete(path: RestAPI.Paths.devicesRemove + "/\(id)", credential: credential){ result in
            switch(result){
            case .success(let response):
                if(response.statusCode == 200){
                    onComplete(.success(()))
                }else if response.statusCode == 400 {
                    onComplete(.failure(.deviceNotFound))
                }
            case .failure(let error):
                print(error)
                onComplete(.failure(.ioError))
            }
        }
    }
        
    func saveData(deviceId: String, samples: [DataSample], currentLocation: Location, apikey: ApiKey, onComplete: @escaping (DeviceOperationResult) -> Void) {
        var uploads = [Upload]()
        
        let locations = [currentLocation]
            .map { $0.toJson }
            .chunked(into: AwsDeviceManager.uploadChunkSize)
            .map(JSON.init)
        let chunkedEvents = samples.eventSamples
            .map { $0.toJson }
            .chunked(into: AwsDeviceManager.uploadChunkSize)
            .map(JSON.init)
        let chunkedTelemetry = samples.sensorSamples
            .map { $0.toSplittedJson }
            .flatMap { $0 }
            .chunked(into: AwsDeviceManager.uploadChunkSize)
            .map(JSON.init)
        
        locations.forEach { uploads.append((samples: $0, type: .telemetry)) }
        chunkedEvents.forEach { uploads.append((samples: $0, type: .events)) }
        chunkedTelemetry.forEach { uploads.append((samples: $0, type: .telemetry)) }

        multipleUploads(uploads, deviceId: deviceId, apikey: apikey, completion: onComplete)
    }
    
    func loadData<T>(deviceId: AssetTrackingDeviceId, from startDate: Date, to endDate: Date, resultType: T.Type, onComplete: @escaping (DeviceDataOperationResult) -> Void) {
        let paramType: String
        
        if type(of: Location.self) == type(of: resultType) {
            paramType = "geolocation"
        } else if type(of: SensorDataSample.self) == type(of: resultType) {
            paramType = "telemetry"
        } else {
            paramType = "events"
        }
        
        let params: KeyValuePairs = ["devices": deviceId,
                                     "timestampEnd": endDate.timestamp,
                                     "timestampStart": startDate.timestamp,
                                     "type": paramType]
        
        api.get(path: RestAPI.Paths.dataGet, params: params, credential: credential) { result in
            guard case .success(let response) = result else { return onComplete(.failure(.ioError)) }
            
            guard response.statusCode == 200,
                  let data = response.data,
                  let sensorResponse = try? JSONDecoder().decode([SensorDataResponse].self, from: data) else {
                return onComplete(.failure(.deviceNotFound))
            }
            let items = sensorResponse.flatMap { $0 } ?? []
            let itemsFlat = items.flatMap { $0.values } ?? []
            onComplete(.success(itemsFlat))
        }
    }
}

private extension AwsDeviceManager {
    
    func getDeviceProfiles(completion: @escaping (DeviceProfilesOperationResult) -> Void) {
        api.get(path: RestAPI.Paths.deviceProfiles, credential: credential) { result in
            switch(result) {
            case .success(let response):
                guard 200 ..< 300 ~= response.statusCode,
                      let data = response.data,
                      let deviceProfiles = try? JSONDecoder().decode([DeviceProfile].self, from: data),
                      let deviceProfile = deviceProfiles.first else {
                    return completion(.failure(.missingDeviceProfiles))
                }
                completion(.success(deviceProfiles))
            case .failure(let error):
                completion(.failure(.ioError))
            }
        }
    }
    
    func getDefaultDeviceProfile(completion: @escaping (DeviceProfileOperationResult) -> Void) {
        let params: KeyValuePairs = ["default_profiles": "true"]
        api.get(path: RestAPI.Paths.deviceProfiles, params: params, credential: credential) { result in
            switch(result) {
            case .success(let response):
                guard 200 ..< 300 ~= response.statusCode,
                      let data = response.data,
                      let deviceProfiles = try? JSONDecoder().decode([DeviceProfile].self, from: data),
                      let deviceProfile = deviceProfiles.first else {
                    return completion(.failure(.missingDeviceProfiles))
                }
                completion(.success(deviceProfile))
            case .failure(let error):
                completion(.failure(.ioError))
            }
        }
    }
    
    func getApiKey(completion: @escaping (DeviceApiKeyOperationResult) -> Void) {
        api.get(path: RestAPI.Paths.apiKey, credential: credential) { result in
            switch(result) {
            case .success(let response):
                guard 200 ..< 300 ~= response.statusCode,
                      let data = response.data,
                      let apiKeys = try? JSONDecoder().decode([ApiKey].self, from: data),
                      let apiKey = apiKeys.first else {
                    return completion(.failure(.missingApiKey))
                }
                completion(.success(apiKey))
            case .failure(let error):
                completion(.failure(.ioError))
            }
        }
    }
    
    func postApiKey(completion: @escaping (Result<Void, DeviceOperationError>) -> Void) {
        var json = JSON()
        json["label"].stringValue = "apiKey"
        
        guard let data = try? json.rawData() else {
            completion(.failure(.ioError))
            return
        }
        
        api.post(path: RestAPI.Paths.apiKey, data: data, credential: credential) { result in
            
            switch(result) {
            case .success(let response):
                guard 200 ..< 300 ~= response.statusCode else {
                    return completion(.failure(.missingApiKey))
                }
                completion(.success(())) // 2xx is OK, ignore result payload
            case .failure(let error):
                completion(.failure(.ioError))
            }
        }
    }
    
    func multipleUploads(_ uploads: [Upload], deviceId: String, apikey: ApiKey, completion: @escaping (DeviceOperationResult) -> Void) {
        for (index, element) in uploads.enumerated() {
            let taskCompletion = (index == uploads.count - 1) ? completion : { result in }
                
            upload(element.samples, deviceId: deviceId, type: element.type, apikey: apikey, completion: taskCompletion)
        }
    }
        
    func upload(_ samples: JSON, deviceId: String, type: UploadType, apikey: ApiKey, completion: @escaping (Result<Void, DeviceOperationError>) -> Void) {
        var jsonObj = JSON()
        jsonObj["device_id"].stringValue = deviceId
        //jsonObj["type"].stringValue = type.rawValue
        jsonObj["values"] = samples
        
        guard let data = try? jsonObj.rawData() else {
            return completion(.failure(.upload))
        }
        
        let headers = ["Authorization": "\(apikey.owner).\(apikey.apiKey)"]
        
        if(type.rawValue == "telemetry"){
            api.post(path: RestAPI.Paths.dataSendTelemetry, data: data, headers: headers) { result in
                switch(result) {
                case .success:
                    completion(.success(()))
                case .failure:
                    completion(.failure(.upload))
                }
            }
        }else{
            api.post(path: RestAPI.Paths.dataSendTelemetry, data: data, headers: headers) { result in
                switch(result) {
                case .success:
                    completion(.success(()))
                case .failure:
                    completion(.failure(.upload))
                }
            }
        }
        
    }
}

/// Generic Data Sample
extension AwsDeviceManager {
    
    func loadGenericData<T>(deviceId: AssetTrackingDeviceId, from startDate: Date, to endDate: Date, resultType: T.Type, onComplete: @escaping (DeviceGenericDataOperationResult) -> Void) {
        let paramType: String
        
        if type(of: Location.self) == type(of: resultType) {
            paramType = "geolocation"
        } else {
            paramType = "telemetry"
        }
        
        let params: KeyValuePairs = ["devices": deviceId,
                                     "timestampEnd": endDate.timestamp,
                                     "timestampStart": startDate.timestamp,
                                     "type": paramType]
        
        api.get(path: RestAPI.Paths.dataGet, params: params, credential: credential) { result in
            guard case .success(let response) = result else { return onComplete(.failure(.ioError)) }
            
            guard response.statusCode == 200,
                  let data = response.data,
                  let sensorResponse = try? JSONDecoder().decode([GenericDataResponse].self, from: data) else {
                return onComplete(.failure(.deviceNotFound))
            }
            let items = sensorResponse.flatMap { $0 } ?? []
            let itemsFlat = items.flatMap { $0.values } ?? []
            onComplete(.success(itemsFlat))
        }
    }
    
    func saveGenericData(deviceId: String, samples: [GenericSample], currentLocation: Location, apikey: ApiKey, onComplete: @escaping (DeviceOperationResult) -> Void) {
        var uploads = [Upload]()
        
        let locations = [currentLocation]
            .map { $0.toJson }
            .chunked(into: AwsDeviceManager.uploadChunkSize)
            .map(JSON.init)
        let chunkedTelemetry = samples
            .map { $0.toSplittedJson }
            .flatMap { $0 }
            .chunked(into: AwsDeviceManager.uploadChunkSize)
            .map(JSON.init)
        
        locations.forEach { uploads.append((samples: $0, type: .telemetry)) }
        chunkedTelemetry.forEach { uploads.append((samples: $0, type: .telemetry)) }

        multipleUploads(uploads, deviceId: deviceId, apikey: apikey, completion: onComplete)
    }
    
}
