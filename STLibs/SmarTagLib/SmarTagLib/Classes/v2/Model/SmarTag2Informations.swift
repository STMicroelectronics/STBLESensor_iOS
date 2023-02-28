//
//  SmarTag2Informations.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - SmarTag2Data
public struct SmarTag2Data {
    public var header: SmarTag2Header
    public var virtualSensorConfiguration: [SmarTag2VirtualSensorConfiguration]
    public let extremes: [SmarTag2VirtualSensorExtreme]
    public let sampleCounter: Int
    public let lastSamplePointer: Int
    public let dataSamples: [SmarTag2DataSample]
}

// MARK: - SmarTag2Header
public struct SmarTag2Header {
    public let baseInformation: SmarTag2BaseInformation
    public var virtualSensorInformation: SmarTag2VirtualSensorInformation
    public var timestamp: SmarTag2Timestamp
}

// MARK: - SmarTag2BaseInformation
public struct SmarTag2BaseInformation{
    public let id:Data?
    public let protocolVersion:UInt8
    public let protocolRevision:UInt8
    public let boardID:UInt8
    public let firmwareID:UInt8
    
    init(id: Data?, protocolVersion:UInt8, protocolRevision:UInt8, boardID:UInt8, firmwareID:UInt8) {
        self.id = id
        self.protocolVersion = protocolVersion
        self.protocolRevision = protocolRevision
        self.boardID = boardID
        self.firmwareID = firmwareID
    }
    
    public var idStr:String?{
        get {
            if let id = id {
                return tagIdentifierToString(id: id)
            }else{
                return nil
            }
        }
    }
}

// MARK: - SmarTag2VirtualSensorInformation
public struct SmarTag2VirtualSensorInformation {
    public let rfu: UInt8
    public var numberVirtualSensor: UInt8
    public var sampleTime: UInt16
    
    public init(rfu:UInt8, numberVirtualSensor: UInt8, sampleTime: UInt16) {
        self.rfu = rfu
        self.numberVirtualSensor = numberVirtualSensor
        self.sampleTime = sampleTime
    }
}

// MARK: - SmarTag2Timestamp
public struct SmarTag2Timestamp {
    public var timestamp: UInt32
    
    init(timestamp: UInt32) {
        self.timestamp = timestamp
    }
}

// MARK: - SmarTag2VirtualSensorConfiguration
public struct SmarTag2VirtualSensorConfiguration {
    public let id: Int
    public var enabled: Bool = false
    public let sensorName: String
    public let thresholdName: String
    public let thUsageType: Int?
    public let th1: Double?
    public let th2: Double?
    
    public init(id: Int, enabled: Bool, sensorName: String, thresholdName: String, thUsageType: Int, th1: Double?, th2: Double?) {
        self.id = id
        self.enabled = enabled
        self.sensorName = sensorName
        self.thresholdName = thresholdName
        self.thUsageType = thUsageType
        self.th1 = th1
        self.th2 = th2
    }
}

// MARK: - SmarTag2VirtualSensorConfiguration
public struct SmarTag2VirtualSensorExtreme {
    public let id: Int
    public let type: String
    public let sensorName: String
    public let thresholdName: String
    public var min: SmarTag2Extreme?
    public var max: SmarTag2Extreme?
    
    init(id: Int, type: String, sensorName: String, thresholdName: String, min: SmarTag2Extreme?, max: SmarTag2Extreme?) {
        self.id = id
        self.type = type
        self.sensorName = sensorName
        self.thresholdName = thresholdName
        self.min = min
        self.max = max
    }
}

public struct SmarTag2Extreme {
    public let timestamp: Date?
    public let value: Double?
    
    init(timestamp: Date?, value: Double?) {
        self.timestamp = timestamp
        self.value = value
    }
}

// MARK: - SmarTag2DataSample
public struct SmarTag2DataSample {
    public let id: Int
    public let type: String
    public let date: Date?
    public let value: Double?
    
    init(id: Int, type: String, date: Date?, value: Double?) {
        self.id = id
        self.type = type
        self.date = date
        self.value = value
    }
}
