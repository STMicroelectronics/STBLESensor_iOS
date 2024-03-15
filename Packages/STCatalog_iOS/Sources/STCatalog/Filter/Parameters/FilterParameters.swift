//
//  FilterParameters.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STDemos

public struct FilterParameters {
    public let orderingBy: OrderByGroup
    public let demosGroup: [DemoGroup]
}

public enum OrderByGroup: String, CaseIterable {
    case none = "None"
    case alphabetical = "Alphabetical"
    case releaseDate = "Release Date"
}
