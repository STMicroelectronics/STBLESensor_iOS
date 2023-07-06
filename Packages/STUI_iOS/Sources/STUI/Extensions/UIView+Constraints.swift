//
//  UIView+Extensions.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public typealias Constraint = (_ child: UIView, _ parent: UIView?) -> NSLayoutConstraint?

public extension UIView {

    static var centerSuperviewConstraints: [Constraint] {
        [
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ]
    }

    static var fitToSuperViewConstraints: [Constraint] {
        [
            equal(\.topAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor),
            equal(\.leadingAnchor)
        ]
    }

    func debugBorder(_ borderColor: UIColor = .red) {
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
    }

    func add(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }

    func setDimensionContraints(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width {
            if let constraint = constraints.first(where: { $0.firstAttribute == .width || $0.secondAttribute == .width }) {
                constraint.constant = width
            } else {
                widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }

        if let height = height {
            if let constraint = constraints.first(where: { $0.firstAttribute == .height || $0.secondAttribute == .height }) {
                constraint.constant = height
            } else {
                heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
    }

    func addSubview(_ view: UIView, constraints: [Constraint]) {
        addSubview(view)
        view.activate(constraints: constraints)
    }

    func addSubview(_ view: UIView, margin: Margin) {
        addSubview(view)
        view.activate(constraints: [
            equal(\.topAnchor, constant: margin.top),
            equal(\.bottomAnchor, constant: -margin.bottom),
            equal(\.trailingAnchor, constant: -margin.right),
            equal(\.leadingAnchor, constant: margin.left)
        ])
    }

    func addSubviewAndFit(_ view: UIView, top: CGFloat = 0, trailing: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0) {
        addSubview(view)
        view.addFitToSuperviewConstraints(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    func addSubviewAndFit(_ view: UIView) {
        add(view)
        view.addFitToSuperviewConstraints()
    }

    func addSubviewAndCenter(_ view: UIView) {
        addSubview(view, constraints: [
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ])
    }

    func addFitToSuperviewConstraints(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
        guard let superview = superview else {
            return assertionFailure("The view must have a superview!")
        }

        translatesAutoresizingMaskIntoConstraints = false

        superview.addConstraint(NSLayoutConstraint(item: self,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .top,
                                                   multiplier: 1.0,
                                                   constant: top))
        superview.addConstraint(NSLayoutConstraint(item: self,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .leading,
                                                   multiplier: 1.0,
                                                   constant: leading))

        let bottom = NSLayoutConstraint(item: superview,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: bottom)
        bottom.priority = UILayoutPriority(999)
        superview.addConstraint(bottom)

        superview.addConstraint(NSLayoutConstraint(item: superview,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .trailing,
                                                   multiplier: 1.0,
                                                   constant: trailing))

        updateConstraints()
    }

    func insertSubview(_ view: UIView, at index: Int, constraints: [Constraint]) {
        insertSubview(view, at: index)
        view.activate(constraints: constraints)
    }

    //  MARK: Contraints Activation

    func activate(constraints: [Constraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.compactMap { constraint in
            constraint(self, superview)
        })
    }
}

public func equal<L, Axis>(_ to: KeyPath<UIView, L>) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        guard let parent = parent else { return nil }
        return view[keyPath: to].constraint(equalTo: parent[keyPath: to])
    }
}

public func equal<L, Axis>(_ to: KeyPath<UIView, L>, constant: CGFloat) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        guard let parent = parent else { return nil }
        return view[keyPath: to].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

public func equal<L, Axis>(_ from: KeyPath<UIView, L>,
                           toView: UIView,
                           withAnchor: KeyPath<UIView, L>,
                           constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: from].constraint(equalTo: toView[keyPath: withAnchor], constant: constant)
    }
}

public func equal<L, Axis>(_ from: KeyPath<UIView, L>, to: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        guard let parent = parent else { return nil }
        return view[keyPath: from].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

public func equalDimension<L>(_ keyPath: KeyPath<UIView, L>, to constant: CGFloat) -> Constraint where L: NSLayoutDimension {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}
