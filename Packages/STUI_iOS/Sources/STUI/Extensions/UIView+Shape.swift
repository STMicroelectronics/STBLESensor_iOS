//
//  UIView+Shape.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public enum Side {
    case top
    case left
    case bottom
    case right
    case all
}

public struct ShapeLayout {
    let color: UIColor
    let borderColor: UIColor
    let width: CGFloat
    let side: Side
    let cornerRadius: CGFloat
    let overlay: Bool

    public init(color: UIColor,
                borderColor: UIColor,
                width: CGFloat,
                side: Side,
                cornerRadius: CGFloat,
                overlay: Bool) {
        self.color = color
        self.borderColor = borderColor
        self.width = width
        self.side = side
        self.cornerRadius = cornerRadius
        self.overlay = overlay
    }
}

public extension UIView {

    @discardableResult
    func apply(layout: ShapeLayout) -> UIView {

        let borderView = UIView(frame: .zero)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = layout.color
        borderView.layer.borderColor = layout.borderColor.cgColor
        borderView.layer.cornerRadius = layout.cornerRadius
        borderView.layer.borderWidth = layout.width

        if layout.overlay {
            addSubview(borderView)
        } else {
            insertSubview(borderView, at: 0)
        }

        switch layout.side {
        case .top:

            NSLayoutConstraint.activate([
                borderView.topAnchor.constraint(equalTo: topAnchor),
                borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                borderView.heightAnchor.constraint(equalToConstant: 1.0)
            ])

        case .left:

            NSLayoutConstraint.activate([
                borderView.topAnchor.constraint(equalTo: topAnchor),
                borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                borderView.widthAnchor.constraint(equalToConstant: 1.0)
            ])

        case .bottom:

            NSLayoutConstraint.activate([
                borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                borderView.heightAnchor.constraint(equalToConstant: 1.0)
            ])

        case .right:

            NSLayoutConstraint.activate([
                borderView.topAnchor.constraint(equalTo: topAnchor),
                borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                borderView.widthAnchor.constraint(equalToConstant: 1.0)
            ])

        case .all:
            borderView.activate(constraints: UIView.fitToSuperViewConstraints)
        }

        return borderView
    }

    func applyShadow(with color: UIColor = .black,
                     alpha: Float = 0.3,
                     offset: CGSize = CGSize(width: 0.0, height: 0.0),
                     path: UIBezierPath? = nil) {
        isOpaque = false
        clipsToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowPath = path?.cgPath
    }

}
