//
//  FontLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public enum FontLayout {
    private static var fontSizeBaseUnit: CGFloat {
        let width = UIScreen.main.bounds.width
        let size: CGFloat = width >= 360 ? 15 : 13
        return size
    }

    public static func font(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }

    public static func font(rel: Float, weight: UIFont.Weight = .regular) -> UIFont {
        let size = fontSizeBaseUnit * CGFloat(rel)
        return font(size: size, weight: weight)
    }

    
}
