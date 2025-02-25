//
//  PlotUtil.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI

func currentTimeInMilliSeconds() -> UInt64 {
    let since1970 = Date().timeIntervalSince1970
    return UInt64(since1970 * 1000)
}

public struct PlotEntry {
    public let x: UInt64
    public let y: [Float]

    public init(x: UInt64, y: [Float]) {
        self.x = x
        self.y = y
    }
}

enum PlotStatus {
    case idle
    case plotting
}

let lineConfigColors = [
    ColorLayout.blue.light,
    ColorLayout.red.light,
    ColorLayout.green.light,
    ColorLayout.ochre.light,
    ColorLayout.yellow.light,
    ColorLayout.systemBlack.light
]
