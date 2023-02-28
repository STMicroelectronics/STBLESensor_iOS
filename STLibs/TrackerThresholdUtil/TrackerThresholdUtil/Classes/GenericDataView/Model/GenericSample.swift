//
//  Sample.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GenericSample {
    public let id: Int
    public let type: String
    public let date: Date?
    public let value: Double?
    public let technologySource: String?
    
    public init(id: Int, type: String, date: Date?, value: Double?, technologySource: String? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.value = value
        self.technologySource = technologySource
    }
}

public extension Array where Element == GenericSample {
    var genericSamples: [GenericSample] {
        get {
            compactMap { sample in
                guard case (let data) = sample else { return nil }
                return data
            }
            .sorted { $0.date! < $1.date! }
        }
    }
}

