//
//  RestAPIResponse.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 30/10/2020.
//

import Foundation

struct RestAPIResponse {
    let statusCode: Int
    let body: String?
    let headers: [String: String]
    let data: Data?
    
    init(statusCode: Int, body: String?, headers: [String: String], data: Data? = nil) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
        self.data = data
    }
}

extension RestAPIResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case statusCode
        case body
        case headers
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let strStatus = try values.decode(String.self, forKey: .statusCode)
        statusCode = Int(strStatus)!
        body = try values.decodeIfPresent(String.self, forKey: .body)
        headers = try values.decode(Dictionary<String,String>.self, forKey: .headers)
        data = nil
    }
}
