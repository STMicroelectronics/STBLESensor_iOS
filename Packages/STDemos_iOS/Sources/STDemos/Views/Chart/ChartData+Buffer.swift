//
//  ChartData+Buffer.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import DGCharts

public extension ChartData {
    func add(channelsEntries: [[ChartDataEntry]], visibleWindowSize: Int) {

        var channelsEntries = channelsEntries
//        var channelsEntries = channelsEntries.map { Array<Any>.resample(array: $0, toSize: 1) }

        for (index, channel) in channelsEntries.enumerated() {

            let dataset = self.dataSet(at: index)

            for _ in 0..<channel.count {
                let element = channelsEntries[index].removeFirst()
                appendEntry(element, toDataSet: index)

                let entryCount = dataset?.entryCount ?? 0

                if entryCount > visibleWindowSize {
                    dataset?.removeFirst()
                }
            }
        }
    }
}
