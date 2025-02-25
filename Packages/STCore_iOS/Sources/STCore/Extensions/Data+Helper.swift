//
//  Data+Helper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Data {

    mutating func append(_ string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
