//
//  Margin.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Margin {
    public let top: CGFloat
    public let bottom: CGFloat
    public let left: CGFloat
    public let right: CGFloat

    public static let card = Margin(top: 10, bottom: 10, left: 20, right: 20)

    public static let standard = Margin(top: 5, bottom: 5, left: 10, right: 10)

    public static let zero = Margin(top: 0, bottom: 0, left: 0, right: 0)
}
