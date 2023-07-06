//
//  UIEdgeInsets+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension UIEdgeInsets {

    static var standard = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    static var standardEmbed = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    static var standardTopBottom = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)

    func top(_ top: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: self.left, bottom: self.bottom, right: self.right)
    }

    func bottom(_ bottom: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: self.top, left: self.left, bottom: bottom, right: self.right)
    }

    func left(_ left: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: self.top, left: left, bottom: self.bottom, right: self.right)
    }

    func right(_ right: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: right)
    }
}
