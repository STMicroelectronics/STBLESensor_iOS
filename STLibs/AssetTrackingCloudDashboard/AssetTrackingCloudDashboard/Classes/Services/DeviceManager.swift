//
//  DeviceManagerProtocol.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 30/08/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation
import AssetTrackingDataModel
import TrackerThresholdUtil

public enum DeviceOperationError: Error {
    case deviceAlreadyRegistered
    case deviceNotFound
    case ioError
    case missingToken
    case missingApiKey
    case missingDeviceProfiles
    case upload
}

public typealias DeviceOperationResult = Result<Void, DeviceOperationError>
public typealias DeviceListOperationResult = Result<[AssetTrackingDevice], DeviceOperationError>
public typealias DeviceAddOperationResult = Result<AssetTrackingDevice, DeviceOperationError>
public typealias DeviceApiKeyOperationResult = Result<ApiKey, DeviceOperationError>
public typealias DeviceProfileOperationResult = Result<DeviceProfile, DeviceOperationError>
public typealias DeviceProfilesOperationResult = Result<[DeviceProfile], DeviceOperationError>
public typealias DeviceDataOperationResult = Result<[SensorDataResponseItem], DeviceOperationError>
public typealias DeviceGenericDataOperationResult = Result<[GenericDataResponseItem], DeviceOperationError>

public protocol DeviceManager {
    func listDevices(onComplete: @escaping (DeviceListOperationResult) -> Void)
    func addDevice(device:AssetTrackingDevice, name: String, certificate: String?, macaddress: String?, deviceprofile: String?, devEui: String?, onComplete: @escaping (DeviceAddOperationResult) -> Void)
    func apiKey(completion: @escaping (DeviceApiKeyOperationResult) -> Void)
    func defaultDeviceProfile(completion: @escaping (DeviceProfileOperationResult) -> Void)
    func deviceProfiles(completion: @escaping (DeviceProfilesOperationResult) -> Void)
    func removeDevice(id:AssetTrackingDeviceId, onComplete: @escaping (DeviceOperationResult) -> Void)
    func saveData(deviceId: AssetTrackingDeviceId, samples: [DataSample], currentLocation: Location, apikey: ApiKey, onComplete: @escaping (DeviceOperationResult) -> Void)
    func saveGenericData(deviceId: AssetTrackingDeviceId, samples: [GenericSample], currentLocation: Location, apikey: ApiKey, onComplete: @escaping (DeviceOperationResult) -> Void)
    func loadData<T>(deviceId: AssetTrackingDeviceId, from startDate: Date, to endDate: Date, resultType: T.Type, onComplete: @escaping (DeviceDataOperationResult) -> Void)
    func loadGenericData<T>(deviceId: AssetTrackingDeviceId, from startDate: Date, to endDate: Date, resultType: T.Type, onComplete: @escaping (DeviceGenericDataOperationResult) -> Void)
}
