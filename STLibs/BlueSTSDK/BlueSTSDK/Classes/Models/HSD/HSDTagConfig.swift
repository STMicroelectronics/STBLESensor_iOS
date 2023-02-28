//
//  HSDTagConfig.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 29/01/21.
//

import Foundation

public class HSDTagConfigContainer: Codable {
    public let tagConfig: HSDTagConfig
}

public class HSDTagConfig: Codable {
    public let maxTagsPerAcq: Int
    public let swTags: [HSDTag]
    public let hwTags: [HSDTag]
    
    public func updateTypes() {
        swTags.forEach { $0.type = .software }
        hwTags.forEach { $0.type = .hardware }
    }
}
