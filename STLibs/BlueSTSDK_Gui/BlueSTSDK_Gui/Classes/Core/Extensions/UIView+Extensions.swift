//
//  UIView+Extensions.swift
//
//  Created by Dimitri Giani on 12/01/21.
//

import UIKit

public typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

public extension UIView {
    var frameSize: CGSize {
        get {
            self.frame.size
        }
        set {
            var frame: CGRect = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var frameOrigin: CGPoint {
        get {
            self.frame.origin
        }
        set {
            var frame: CGRect = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    func removeAllSubviews() {
        if let stack = self as? UIStackView {
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        } else {
            subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    func setShadow(_ color:UIColor?, offset:CGSize?, opacity: CGFloat?, radius:CGFloat?)
    {
        if let shadowColor = color {
            layer.shadowColor = shadowColor.cgColor
        }
        
        if let shadowOffset = offset {
            layer.shadowOffset = shadowOffset
        }
        
        if let shadowOpacity = opacity {
            layer.shadowOpacity = Float(shadowOpacity)
        }
        
        if let shadowRadius = radius {
            layer.shadowRadius = shadowRadius
        }
    }
    
    func removeShadow()
    {
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.clear.cgColor
    }

    //    MARK: Class methods
    
    class func fromNib<T:UIView>(withName name:String) -> T
    {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)!.first as! T
    }
    
    class func fromNib<T:UIView>(index: Int = 0) -> T
    {
        let name = String(describing: T.self)
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)![index] as! T
    }
    
    //  MARK: - Constraints
    
    static var centerSuperviewConstraints: [Constraint] {
        return [
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ]
    }
    static var fitToSuperViewConstraints: [Constraint] {
        return [equal(\.topAnchor), equal(\.trailingAnchor), equal(\.bottomAnchor), equal(\.leadingAnchor)]
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
    
    func addSubview(_ view: UIView, constraints: [Constraint])
    {
        addSubview(view)
        view.activate(constraints: constraints)
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
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func addFitToSuperviewConstraints(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
        guard let superview = superview else {
            return assertionFailure("The view must have a superview!")
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        superview.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1.0, constant: top))
        superview.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1.0, constant: leading))
        let bottom = NSLayoutConstraint(item: superview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: bottom)
        bottom.priority = UILayoutPriority(999)
        superview.addConstraint(bottom)
        superview.addConstraint(NSLayoutConstraint(item: superview, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: trailing))
        
        updateConstraints()
    }
    
    func insertSubview(_ view: UIView, at index: Int, constraints: [Constraint])
    {
        insertSubview(view, at: index)
        view.activate(constraints: constraints)
    }
    
    //  MARK: Contraints Activation
    
    func activate(constraints: [Constraint])
    {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { c in
            c(self, superview!)
        })
    }
}

public func equal<L, Axis>(_ to: KeyPath<UIView, L>) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: to].constraint(equalTo: parent[keyPath: to])
    }
}

public func equal<L, Axis>(_ to: KeyPath<UIView, L>, constant: CGFloat) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: to].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

public func equal<L, Axis>(_ from: KeyPath<UIView, L>, toView: UIView, withAnchor: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: from].constraint(equalTo: toView[keyPath: withAnchor], constant: constant)
    }
}

public func equal<L, Axis>(_ from: KeyPath<UIView, L>, to: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: from].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

public func equalDimension<L>(_ keyPath: KeyPath<UIView, L>, to constant: CGFloat) -> Constraint where L: NSLayoutDimension {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}
