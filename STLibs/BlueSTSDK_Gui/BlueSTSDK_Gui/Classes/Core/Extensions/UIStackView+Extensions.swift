//
//  UIStackView+Extensions.swift
//
//  Created by Dimitri Giani on 12/01/21.
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
