//
//  Paths.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 30/10/2020.
//

import Foundation

extension RestAPI {
    enum Paths {
        static let authZ = "/v1/authz-token"
        static let apiKey = "/v1/apikeys"
        
        static let devices = "/v1/devices"
        static let devicesAdd = "/v1/devices"
        static let devicesRemove = "/v1/devices"
        //static let dataSend = "/v1/data"
        static let dataGet = "/v1/data"
        static let dataSendTelemetry = "/v1/telemetry"
        //static let dataSendEvents = "/v1/events"
    }
}
