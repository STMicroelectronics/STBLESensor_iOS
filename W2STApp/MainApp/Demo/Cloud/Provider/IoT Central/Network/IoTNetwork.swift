//
//  IoTNetwork.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Alamofire
import Foundation

class IoTNetwork {
    static let shared = IoTNetwork()
    
    func getTemplates(central: IoTCentralApp, _ completion: @escaping ([IoTTemplate], Error?) -> Void) {
        let api = IoTAPIEndpoint.templates
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, headers: central.headers).responseDecodable(of: IoTResponse<[IoTTemplate]>.self) { response in
            switch response.result {
                case .success(let response):
                    completion(response.value, nil)
                    
                case .failure(let error):
                    completion([], error)
            }
        }
    }
    
    func getDevices(central: IoTCentralApp, _ completion: @escaping ([IoTDevice], Error?) -> Void) {
        let api = IoTAPIEndpoint.devices
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, headers: central.headers).responseDecodable(of: IoTResponse<[IoTDevice]>.self) { response in
            switch response.result {
                case .success(let response):
                    completion(response.value, nil)

                case .failure(let error):
                    debugPrint(error)
                    completion([], error)
            }
        }
    }
    
    func createDevice(device: IoTDeviceTemporary, central: IoTCentralApp, _ completion: @escaping (IoTDevice?, Error?) -> Void) {
        let api = IoTAPIEndpoint.createDevice(id: device.id)
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, method: .put, parameters: device, encoder: JSONParameterEncoder.default, headers: central.headersForPut)
            .responseDecodable(of: IoTDevice.self) { response in
            switch response.result {
                case .success(let device):
                    completion(device, nil)
                    
                case .failure(let error):
                    completion(nil, error)
            }
        }
    }
    
    func updateDeviceName(device: IoTDevice, name: String, central: IoTCentralApp, _ completion: @escaping (Error?) -> Void) {
        let api = IoTAPIEndpoint.deleteDevice(id: device.id)
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, method: .patch, parameters: ["displayName": name], encoder: JSONParameterEncoder.default, headers: central.headersForPut)
            .response { response in
            switch response.result {
                case .success:
                    completion(nil)
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func getDeviceCredentials(device: IoTDevice, central: IoTCentralApp, _ completion: @escaping (IoTDeviceCredentials?, Error?) -> Void) {
        let api = IoTAPIEndpoint.getDeviceCredentials(id: device.id)
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, headers: central.headers)
            .responseDecodable(of: IoTDeviceCredentials.self) { response in
            switch response.result {
                case .success(let response):
                    completion(response, nil)
                    
                case .failure(let error):
                    completion(nil, error)
            }
        }
    }
    
    func deleteDevice(device: IoTDevice, central: IoTCentralApp, _ completion: @escaping (Error?) -> Void) {
        let api = IoTAPIEndpoint.deleteDevice(id: device.id)
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, method: .delete, headers: central.headersForPut)
            .response { response in
            switch response.result {
                case .success:
                    completion(nil)
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func deviceProperties(device: IoTDevice, central: IoTCentralApp, _ completion: @escaping (Error?) -> Void) {
        let api = IoTAPIEndpoint.deviceProperties(id: device.id)
        let url = central.baseURL.appendingPathComponent(api.path)
        
        AF.request(url, headers: central.headers)
            .response { response in
            switch response.result {
                case .success:
                    completion(nil)
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
}
