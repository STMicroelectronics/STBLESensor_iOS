//
//  IoTCentralApp.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Alamofire
import Foundation

struct IoTCentralApp: Codable {
    static let domain = "azureiotcentral.com"
    
    var subdomain: String
    var token: String
    
    var isValid: Bool {
        !subdomain.isEmpty &&
            !token.isEmpty &&
            URL(string: domain) != nil
    }
    
    var domain: String {
        "\(subdomain).\(IoTCentralApp.domain)"
    }
    
    var baseURL: URL {
        URL(string: "https://\(domain)")!
    }
}

extension IoTCentralApp {
    var headers: HTTPHeaders {
        HTTPHeaders([
            HTTPHeader(name: "Authorization", value: token)
        ])
    }
    
    var headersForPut: HTTPHeaders {
        var headers = self.headers
        headers.add(HTTPHeader(name: "Accept", value: IoTAPIEndpoint.jsonContentType))
        return headers
    }
}
