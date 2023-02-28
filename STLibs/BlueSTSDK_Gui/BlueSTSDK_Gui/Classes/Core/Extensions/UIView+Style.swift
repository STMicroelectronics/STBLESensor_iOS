//
//  UIView+Style.swift
//
//  Created by Dimitri Giani on 13/01/21.
//

import UIKit

public extension UIView {
    func applyShadowedStyle() {
        backgroundColor = .white
        cornerRadius = 6
        setShadow(.black, offset: .zero, opacity: 0.12, radius: 6)
    }
}
