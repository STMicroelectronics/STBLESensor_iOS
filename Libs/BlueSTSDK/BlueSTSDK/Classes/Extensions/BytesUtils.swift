//
//  BytesUtils.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 27/01/21.
//

import Foundation

extension UInt8 {
    var hex: String {
        String(format: "%02x", self)
    }
}

extension Int16 {
    var reversedBytes: [UInt8] {
        let array = Array(withUnsafeBytes(of: self.littleEndian) { Data($0) })
        return array.reversed()
    }

}

extension Data {
    var hex: String {
        map { $0.hex }.joined()
    }
}
