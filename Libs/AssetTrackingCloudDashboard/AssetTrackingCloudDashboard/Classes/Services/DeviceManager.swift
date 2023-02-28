//
//  DeviceManagerProtocol.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 30/08/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation
import AssetTrackingDataModel

public enum DeviceOperationError: Error {
    case deviceAlreadyRegistered
    case deviceNotFound
    case ioError
    case missingToken
    case missingApiKey
    case upload
}

public typealias DeviceOperationResult = Result<Void, DeviceOperationError>
public typealias DeviceListOperationResult = Result<[AssetTrackingDevice], DeviceOperationError>
public typealias DeviceAddOperationResult = Result<AssetTrackingDevice, DeviceOperationError>
public typealias DeviceApiKeyOperationResult = Result<ApiKey, DeviceOperationError>
public typealias DeviceDataOperationResult = Result<[SensorDataResponseItem], DeviceOperationError>

public protocol DeviceManager {
    func listDevices(onComplete: @escaping (DeviceListOperationResult) -> Void)
    func addDevice(device:AssetTrackingDevice, name: String, certificate: String?, onComplete: @escaping (DeviceAddOperationResult) -> Void)
    func apiKey(completion: @escaping (DeviceApiKeyOperationResult) -> Void)
    func removeDevice(id:AssetTrackingDeviceId, onComplete: @escaping (DeviceOperationResult) -> Void)
    func saveData(deviceId: AssetTrackingDeviceId, samples: [DataSample], currentLocation: Location, apikey: ApiKey, onComplete: @escaping (DeviceOperationResult) -> Void)
    func loadData<T>(deviceId: AssetTrackingDeviceId, from startDate: Date, to endDate: Date, resultType: T.Type, onComplete: @escaping (DeviceDataOperationResult) -> Void)
}
