//
//  Filter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

typealias Filters = [Filter]

struct Filter {
    let sensorID: String
    let boardCompatibility: [String]?
    let values: [Value]
}

extension Filter: Codable {
    enum CodingKeys: String, CodingKey {
        case sensorID = "sensorId"
        case boardCompatibility = "board_compatibility"
        case values
    }
}

struct Value: Codable {
    let id: Int
    let powerModes: [PowerMode.Mode]
    let filters: [FilterElement]
}

struct FilterElement: Codable {
    let odrs: [Double]
    let lowPass: [Pass]
    let highPass: [Pass]
}

struct Pass: Codable {
    let label: String
    var value: Int
}

extension Pass {
    func jsonDictionary() -> [String: Any] {
        return [
            "label": label,
            "value": value
        ]
    }
}

extension Pass: Pickable {

    func displayName() -> String {
        return "\(label) Hz"
    }
}

struct EmptyPickable: Pickable {
    func displayName() -> String {
        return "No filter"
    }
}

struct OdrPickable: Pickable {
    var value: Double

    func displayName() -> String {
        return "\(value) Hz"
    }
}

