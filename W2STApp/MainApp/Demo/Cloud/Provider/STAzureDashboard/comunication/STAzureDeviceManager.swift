//
//  STAzureDeviceManager.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation


private struct RegisterDeviceParameters : Encodable{
    let deviceId:String
    let deviceName:String
    let isGateway=false
    
    private enum CodingKeys: String, CodingKey {
      case deviceId
      case deviceName = "userDeviceName"
      case isGateway
    }
}

private struct RegisterDeviceResponse: Decodable{
    let connectionString:String
    
    private enum CodingKeys: String, CodingKey {
        case connectionString
    }
}

internal class STAzureDeviceManager :  STAzureDeviceManagerProtocol {
    private static let BASE_URL = URL(string: "https://stm32ode.azurewebsites.net")!
        
    private let deviceManagerApi:RestAPI
    
    init(authToken:String){
        deviceManagerApi = RestAPI(baseUrl: STAzureDeviceManager.BASE_URL, headerValue: [
            "Accept" : "application/json, text/plain, */*",
            "Content-Type" : "application/json;charset=UTF-8",
            "Authorization" : "Bearer "+authToken
        ])
    }
    
    func register(deviceId:String,deviceName:String, onComplete:@escaping STAzureDeviceRegistrationCallback) {
        
        let params = RegisterDeviceParameters(deviceId: deviceId, deviceName: deviceName)
        guard let jsonParams = try? JSONEncoder().encode(params) else {
            onComplete(.failure(.invalidParameters))
            return
        }
        let urlParam = [ "autoprovisioned" : "false"]
        deviceManagerApi.post(path: "/devices", urlParam: urlParam, requestBody: jsonParams){ result in
            switch (result){
            case .success((let httpResponse,let data)):
                let response =  Self.manageResponse(params,httpResponse, data)
                DispatchQueue.main.async {
                    onComplete(response)
                }
            case .failure(let error):
                let response = Self.managerRestError(error)
                DispatchQueue.main.async {
                    onComplete(response)
                }
            }
        }
        
    }
    
    private static func managerRestError(_ error:RestAPIComunicationError) -> STAzureDeviceRegistrationResult{
           switch(error){
           case .invalidUrl:
               return .failure(.invalidParameters)
           case .invalidResponse:
               return .failure(.invalidResponse)
           case .offline:
               return .failure(.offline)
           case .invalidRequest:
               return .failure(.invalidParameters)
           case .unknown:
               return .failure(.ioError)
//           @unknown default:
//               return .failure(.ioError)
           }
       }
       
    private static func manageResponse(_ requestParam:RegisterDeviceParameters,_ httpResponse:HTTPURLResponse,_ data:Data?) -> STAzureDeviceRegistrationResult{
           if(httpResponse.statusCode == 200){
               if let responseData = data {
                   do{
                       let response = try JSONDecoder().decode(RegisterDeviceResponse.self, from: responseData)
                       let device = STAzureRegisterdDevice(id: requestParam.deviceId,
                                                           name: requestParam.deviceName,
                                                           connectionString: response.connectionString)
                       return .success(device)
                   }catch {
                       return .failure(.invalidResponse)
                   }
               }else{
                   return .failure(.invalidResponse)
               }
           }else{
                return .failure(.accessForbidden)
           }
       }
    
}
