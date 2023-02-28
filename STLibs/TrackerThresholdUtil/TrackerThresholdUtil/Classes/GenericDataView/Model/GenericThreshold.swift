//
//  Threshold.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GenericThreshold {
    public let id: Int
    public let name: String
    public let type: String
    public let sensorName: String?
    public let minValue: Double?
    public let maxValue: Double?
    public let scaleFactor: Double?
    public let negativeOffset: Double?
    public let unit: String?
    
    public init(id: Int, name: String, type: String, sensorName: String?, minValue: Double?, maxValue: Double?, scaleFactor: Double?, negativeOffset: Double?, unit: String?) {
        self.id = id
        self.name = name
        self.sensorName = sensorName
        self.type = type
        self.minValue = minValue
        self.maxValue = maxValue
        self.scaleFactor = scaleFactor
        self.negativeOffset = negativeOffset
        self.unit = unit
    }
}
