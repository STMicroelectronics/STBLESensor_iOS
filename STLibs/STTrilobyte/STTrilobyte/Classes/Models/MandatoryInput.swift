//
//  MandatoryInput.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

struct MandatoryInput {
    let functions: [Int]
    let sensors: [Int]
}

extension MandatoryInput: Codable {
    enum CodingKeys: String, CodingKey {
        case functions
        case sensors
    }
}
