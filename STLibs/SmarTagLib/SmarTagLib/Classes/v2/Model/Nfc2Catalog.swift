//
//  NfcCatalog.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - NfcCatalog
public struct Nfc2Catalog {
    public var nfcV2firmwares: [Nfc2Firmware]
}

extension Nfc2Catalog: Codable {
    enum CodingKeys: String, CodingKey {
        case nfcV2firmwares = "nfc_v2"
    }
}

// MARK: - Nfc2Firmware
public struct Nfc2Firmware {
    public var nfcDevID: String
    public var nfcFwID: String
    public var brdName: String
    public var fwName: String
    public var fwVersion: String
    public var bitLengthVirtualSensorsId: Int
    public var virtualSensors: [VirtualSensor]
}

extension Nfc2Firmware: Codable {
    enum CodingKeys: String, CodingKey {
        case nfcDevID = "nfc_dev_id"
        case nfcFwID = "nfc_fw_id"
        case brdName = "brd_name"
        case fwName = "fw_name"
        case fwVersion = "fw_version"
        case bitLengthVirtualSensorsId = "bit_length_virtual_sensors_id"
        case virtualSensors = "virtual_sensors"
    }
}

// MARK: - VirtualSensor
public struct VirtualSensor {
    public var sensorName: String
    public var type: String
    public var displayName: String
    public var id: Int
    public var incompatibility: [Incompatibility]
    public var plottable: Bool
    public var threshold: Nfc2Threshold
    public var maxMinFormat: [MaxMinFormat]?
    public var sampleFormat: [SampleFormat]?
}

extension VirtualSensor: Codable {
    enum CodingKeys: String, CodingKey {
        case sensorName = "sensor_name"
        case type, id, incompatibility, plottable, threshold
        case displayName = "display_name"
        case maxMinFormat = "max_min_format"
        case sampleFormat = "sample_format"
    }
}

// MARK: - Incompatibility
public struct Incompatibility {
    public var id: Int
}

extension Incompatibility: Codable {
    enum CodingKeys: String, CodingKey {
        case id
    }
}

// MARK: - MaxMinFormat
public struct MaxMinFormat {
    public var type: String
    public var format: FormatClass
}

extension MaxMinFormat: Codable {
    enum CodingKeys: String, CodingKey {
        case type, format
    }
}

// MARK: - FormatClass
public struct FormatClass {
    public var displayName: String?
    public var formatType: String?
    public var bitLength: Int
    public var comment: String?
    public var offset: Int?
    public var scaleFactor: Double?
    public var unit: String?
}

extension FormatClass: Codable {
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case formatType = "format_type"
        case bitLength = "bit_length"
        case scaleFactor = "scale_factor"
        case comment, offset, unit
    }
}

// MARK: - SampleFormat
public struct SampleFormat {
    public var type: String
    public var format: Nfc2ThresholdDetail?
}

extension SampleFormat: Codable {
    enum CodingKeys: String, CodingKey {
        case type, format
    }
}

// MARK: - NfcThreshold
public struct Nfc2Threshold {
    public var bitLengthID: Int
    public var bitLengthMod: Int
    public var offset: Double?
    public var scaleFactor: Double?
    public var min: Double?
    public var max: Double?
    public var unit: String?
    public var thLow: Nfc2ThresholdDetail
    public var thHigh: Nfc2ThresholdDetail?
}

extension Nfc2Threshold: Codable {
    enum CodingKeys: String, CodingKey {
        case bitLengthID = "bit_length_id"
        case bitLengthMod = "bit_length_mod"
        case scaleFactor = "scale_factor"
        case thLow = "th_low"
        case thHigh = "th_high"
        case offset, min, max, unit
    }
}

// MARK: - Nfc2ThresholdDetail
public struct Nfc2ThresholdDetail {
    public var displayName: String?
    public var format: String?
    public var bitLength: Int?
    public var comment: String?
}

extension Nfc2ThresholdDetail: Codable {
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case bitLength = "bit_length"
        case format, comment
    }
}
