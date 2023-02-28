//
//  ApiKey.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 05/11/2020.
//

import Foundation

public struct ApiKey: Decodable {
    public let apiKey: String
    public let label: String
    public let enabled: Bool
    public let owner: String
    public let createTimestamp: Int64
    public let enabledUpdateTimestamp: Int64
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "apikey"
        case label
        case enabled
        case owner
        case createTimestamp = "create_timestamp"
        case enabledUpdateTimestamp = "enabled_update_timestamp"
    }
}
