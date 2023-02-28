//
//  CodableWrapper.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 11/11/2020.
//

import Foundation

public struct CodableWrapper<T> {
    let value: T?
}

extension CodableWrapper: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let data = try container.decode(Data.self, forKey: .data)
        value = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let data = try NSKeyedArchiver.archivedData(withRootObject: value as Any, requiringSecureCoding: false)
        try container.encode(data, forKey: .data)
    }
}
