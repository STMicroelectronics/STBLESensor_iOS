//
//  Descriptor.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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
