//
//  UInt32+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
}
