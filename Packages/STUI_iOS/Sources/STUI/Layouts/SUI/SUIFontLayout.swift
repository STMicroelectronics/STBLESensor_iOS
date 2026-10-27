//
//  SUIFontLayout.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public enum SUIFontLayout {
    private static var fontSizeBaseUnit: CGFloat {
        let width = UIScreen.main.bounds.width
        return width >= 360 ? 15 : 13
    }

    public static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    public static func font(rel: CGFloat, weight: Font.Weight = .regular) -> Font {
        let size = fontSizeBaseUnit * rel
        return .system(size: size, weight: weight)
    }
}
