//
//  STAzureUserManager.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 13/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

fileprivate struct LoginParameters : Encodable{
    let password : String
    let email:String
    let rememberMe = true
    
    init(name:String, password:String){
        email = name + "@dummy.com"
        self.password = password
    }
        
    private enum CodingKeys: String, CodingKey {
      case password
      case email
      case rememberMe
    }
}

fileprivate struct LoginResponse :STAzureAuthData, Decodable {
    let token:String
    let expiringInterval:Int

    private enum CodingKeys: String, CodingKey {
      case token
      case expiringInterval
    }
    
}

internal class STAzureUserManager : STAzureUserManagerProtocol {
    
    private static let BASE_URL = URL(string: "https://stm32ode.azurewebsites.net")!
    
    private let loginService = RestAPI(baseUrl: STAzureUserManager.BASE_URL, headerValue: [
        "Accept" : "application/json, text/plain, */*",
        "Content-Type" : "application/json;charset=UTF-8"
    ])
    
    func login(name: String, password: String, onComplete: @escaping STAzureLoginCallback) {
        let params = LoginParameters(name: name, password: password)
        guard let jsonParams = try? JSONEncoder().encode(params) else {
            onComplete(.failure(.invalidParameters))
            return
        }
        loginService.post(path: "/user/login", urlParam: [:], requestBody: jsonParams){ result in
            switch (result){
            case .success((let httpResponse,let data)):
                let response =  Self.manageResponse(httpResponse, data)
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
        
    private static func managerRestError(_ error:RestAPIComunicationError) -> STAzureLoginResult{
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
        }
    }
    
    private static func manageResponse(_ httpResponse:HTTPURLResponse,_ data:Data?) -> STAzureLoginResult{
        if(httpResponse.statusCode == 200){
            if let responseData = data {
                do{
                    let response = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                    return .success(response)
                }catch {
                    return .failure(.invalidResponse)
                }
            }else{
                return .failure(.invalidResponse)
            }
        }else{
            if(httpResponse.statusCode == 403){
                return .failure(.accessForbidden)
            }else{
                return .failure(.invalidParameters)
            }
        }
    }
    
    func getDeviceManager(authData: STAzureAuthData) -> STAzureDeviceManagerProtocol? {
        guard let data = authData as? LoginResponse else{
            return nil
        }
        return STAzureDeviceManager(authToken: data.token)
    }
        
    private func buildRequestUrl(path:String, urlParam:[String:String] = [:])->URL?{
        var urlComponent = URLComponents(url: Self.BASE_URL, resolvingAgainstBaseURL: false)
        urlComponent?.path = path
        urlComponent?.queryItems = urlParam.toQueryItem
        return urlComponent?.url
    }
    
}

fileprivate extension Dictionary where Key == String, Value == String {
    var toQueryItem: [URLQueryItem]{
        return self.map{ key, value in URLQueryItem(name: key, value: value)}
    }
}
