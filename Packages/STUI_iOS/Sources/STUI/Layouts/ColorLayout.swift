//
//  ColorLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public protocol Colorable {
    
    var light: UIColor { get set }
    var dark: UIColor { get set }
    var auto: UIColor { get }
    var autoInverted: UIColor { get }
    
}

public struct ColorLayout: Colorable {
    
    public var light: UIColor
    public var dark: UIColor
    public var auto: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .light {
                    return dark
                } else {
                    return light
                }
            }
        } else {
            return light
        }
    }

    public var autoInverted: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .light {
                    return light
                } else {
                    return dark
                }
            }
        } else {
            return dark
        }
    }
    
    public init(light: String, dark: String) {
        self.light =  UIColor(hex: light)
        self.dark = UIColor(hex: dark)
    }
    
}
