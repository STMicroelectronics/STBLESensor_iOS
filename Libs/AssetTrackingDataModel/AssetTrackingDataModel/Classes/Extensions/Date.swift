//
//  Date.swift
//  AssetTrackingDataModel
//
//  Created by Klaus Lanzarini on 11/11/2020.
//

import Foundation

extension Date {
    public var timestamp: String {
        let timestamp = String(Int(self.timeIntervalSince1970 * 1000))
        return timestamp
    }
    
    public var timestampDouble: Double {
        let timestamp = self.timeIntervalSince1970 * 1000
        return timestamp
    }
}
