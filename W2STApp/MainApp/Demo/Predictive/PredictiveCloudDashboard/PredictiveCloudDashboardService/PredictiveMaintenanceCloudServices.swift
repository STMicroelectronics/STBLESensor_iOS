//
//  PredictiveMaintenanceCloudServices.swift
//  W2STApp

import Foundation
import Alamofire
/** Necessary to reuse base URL - Todo: Remove when refactoring with STLoginModule*/
import AssetTrackingCloudDashboard

enum PMAPIEndpoint {
    
    case devices
    
    var path: String {
        switch self {
            case .devices:
                return "/devices"
        }
    }
}

extension PredictiveMaintenanceCloudServices {
    var headers: HTTPHeaders {
        HTTPHeaders([
            HTTPHeader(name: "Authorization", value: idTokenN!)
        ])
    }
}

class PredictiveMaintenanceCloudServices {
    let baseUrl = Environment.predmntprod.baseUrl
    
    public var idTokenN: String?
    public var accessTokenN: String?
    
    init(idTokenN: String?, accessTokenN: String?) {
        self.idTokenN = idTokenN
        self.accessTokenN = accessTokenN
    }
    
    /** GET -> obtain provisioned devices list */
    public func getPMdevices(_ completion: @escaping ([PMRemoteDevices], Error?) -> Void){
        var devices: [PMRemoteDevices] = []

        if !(idTokenN==nil && accessTokenN==nil){
            let url = "\(baseUrl)/\(PMAPIEndpoint.devices)?accessToken=\(accessTokenN!)"
            
            AF.request(url, headers: headers).responseDecodable(of: PMResponse.self) { response in
                switch response.result {
                    case .success:
                        response.value?.things?.forEach{ thing in
                            devices.append(PMRemoteDevices(thingName: thing.thingName, thingTypeName: thing.thingTypeName, thingArn: thing.thingArn, attributes: thing.attributes, version: thing.version))
                        }
                        completion(devices, nil)
                    case .failure(let error):
                        completion([], error)
                }
            }
        }
    }
    
    /** DELETE -> delete specific device */
    public func deletePMDevice(thingName: String, _ completion: @escaping (Error?) -> Void) {
        if !(idTokenN==nil && accessTokenN==nil){
            let params: Parameters = [
                    "thingName": thingName,
                    "accessToken": accessTokenN!
                ]
            let url = "\(baseUrl)/\(PMAPIEndpoint.devices)"
            
            AF.request(url, method: .delete, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
    
    /** POST -> provisioning new device */
    public func addPMDevice(name: String, thingName: String, _ completion: @escaping (String?, String?, Error?) -> Void) {
        if !(idTokenN==nil && accessTokenN==nil){
            
            let params: Parameters = [
                    "thingName": thingName,
                    "accessToken": accessTokenN!,
                    "attributes": [
                        "name": name,
                        "assetname": "",
                        "fab": name,
                        "group": "",
                        "owner": "",
                        "coordinates": []
                    ],
                    "config": [
                        "Env_Time": 5,
                        "Ine_Time_TDM": 5,
                        "Ine_Time_FDM": 30,
                        "Aco_Time": 2
                    ],
                    "endpoint": "a31pjrd6x4v4ba-ats.iot.eu-west-1.amazonaws.com"
                ]
            
            let url = "\(baseUrl)/\(PMAPIEndpoint.devices)"
            
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .response { response in
                switch response.result {
                    case .success:
                        if !(response.data==nil){
                            let bodyResponse = String(data: response.data!, encoding: String.Encoding.utf8)
                            let data = Data(bodyResponse!.utf8)

                            if !(bodyResponse==nil){
                                do {
                                    let certificateResponse = try JSONDecoder().decode(CertificateResponse.self, from: data)
                                    
                                    let certificate = certificateResponse.certificatePem
                                    let privateKey = certificateResponse.keyPair.privateKey
                                    
                                    completion(certificate, privateKey, nil)
                                } catch { print(error) }
                            }
                        }
                    
                    case .failure(let error):
                        completion(nil, nil, error)
                }
            }
        }
    }
}
