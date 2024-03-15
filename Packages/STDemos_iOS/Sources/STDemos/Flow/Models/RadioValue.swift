//
//  RadioValue.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

struct RadioValue {
    let label: String
    let value: Int
}

extension RadioValue: Codable {
    enum CodingKeys: String, CodingKey {
        case label
        case value
    }
}

extension RadioValue: Checkable {
    var identifier: String {
        return label
    }

    var descr: String {
        return label
    }
}
