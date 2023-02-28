//
//  Filter.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 09/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

typealias Filters = [Filter]

struct Filter {
    let sensorID: String
    let values: [Value]
}

extension Filter: Codable {
    enum CodingKeys: String, CodingKey {
        case sensorID = "sensorId"
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
        return "no_filter".localized()
    }
}

struct OdrPickable: Pickable {
    var value: Double

    func displayName() -> String {
        return "\(value) Hz"
    }
}
