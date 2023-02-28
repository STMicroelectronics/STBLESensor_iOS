//
//  Data+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

extension Data {
    var hexDescription: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
