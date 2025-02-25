//
//  RawPnPLStreamEntry+Chart.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

public extension RawPnPLStreamEntry {

    static var colors: [UIColor] { [
        UIColor(hex: "#FF1B3AA8"),
        UIColor(hex: "#FF1E8537"),
        UIColor(hex: "#FFA8251B"),
        UIColor(hex: "#FF000000"),
        UIColor(hex: "#FF3CB4E6"),
        UIColor(hex: "#FFE6007E")
    ] }

    var lineConfigs: [LineConfig] {

        switch name {
        case "acc", "mag":
            return [LineConfig(name: "X", color: RawPnPLStreamEntry.colors[0]),
                    LineConfig(name: "Y", color: RawPnPLStreamEntry.colors[1]),
                    LineConfig(name: "Z", color: RawPnPLStreamEntry.colors[2])]

        case "temp":
            return [LineConfig(name: "Temp", color: RawPnPLStreamEntry.colors[0])]

        case "press":
            return [LineConfig(name: "Press", color: RawPnPLStreamEntry.colors[0])]

        default:
            var configs: [LineConfig] = []
            for channel in 0..<(channels ?? 1) {
                configs.append(LineConfig(name: "channel \(channel)",
                                          color: channel >= RawPnPLStreamEntry.colors.count ? RawPnPLStreamEntry.colors[0] : RawPnPLStreamEntry.colors[channel]))
            }

            return configs
        }
    }
}
