//
//  UIStackView+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension UIStackView {
    class func getHorizontalStackView(withSpacing spacing: CGFloat, views: [UIView]) -> UIStackView {
        let view = UIStackView(arrangedSubviews: views)
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = spacing
        return view
    }

    class func getVerticalStackView(withSpacing spacing: CGFloat, views: [UIView]) -> UIStackView {
        let view = UIStackView(arrangedSubviews: views)
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = spacing
        return view
    }
}
