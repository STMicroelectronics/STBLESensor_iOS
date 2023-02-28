//
//  UIView+Shape.swift
//  trilobyte
//
//  Created by Stefano Zanetti on 28/11/2018.
//  Copyright © 2018 Codermine. All rights reserved.
//

import UIKit

enum ViewStyle {
    case bottomBorder(insets: UIEdgeInsets, cornerRadius: CGFloat, height: CGFloat)
    case topBorder(insets: UIEdgeInsets, cornerRadius: CGFloat, height: CGFloat)
    case border(insets: UIEdgeInsets, cornerRadius: CGFloat, height: CGFloat)
    case leftBorder(insets: UIEdgeInsets, cornerRadius: CGFloat, height: CGFloat)
    case rightBorder(insets: UIEdgeInsets, cornerRadius: CGFloat, height: CGFloat)
}

private extension UIView {
    
    func configure(with style: ViewStyle) {
        
        guard let superview = superview else { return }
        
        switch style {
        case .topBorder(let insets, let cornerRadius, let height):
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left).isActive = true
            self.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right).isActive = true
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
            self.layer.cornerRadius = cornerRadius
            self.layer.borderWidth = height
            
        case .bottomBorder(let insets, let cornerRadius, let height):
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom).isActive = true
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left).isActive = true
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: insets.right).isActive = true
            self.layer.cornerRadius = cornerRadius
            self.layer.borderWidth = height
            
        case .leftBorder(let insets, let cornerRadius, let height):
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom).isActive = true
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left).isActive = true
            self.widthAnchor.constraint(equalToConstant: height).isActive = true
            self.layer.cornerRadius = cornerRadius
            self.layer.borderWidth = height
            
        case .rightBorder(let insets, let cornerRadius, let height):
            self.widthAnchor.constraint(equalToConstant: height).isActive = true
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom).isActive = true
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: insets.right).isActive = true
            self.layer.cornerRadius = cornerRadius
            self.layer.borderWidth = height
            
        case .border(let insets, let cornerRadius, let height):
            self.isUserInteractionEnabled = false
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom).isActive = true
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left).isActive = true
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: insets.right).isActive = true
            self.layer.cornerRadius = cornerRadius
            self.layer.borderWidth = height
        }
    }

}

extension UIView {
    
    @discardableResult
    func applyStyle(_ style: ViewStyle,
                    fillColor: UIColor?,
                    strokeColor: UIColor?,
                    overlay: Bool) -> UIView {
        
        let borderView = UIView(frame: .zero)
        borderView.backgroundColor = fillColor
        borderView.layer.borderColor = (strokeColor ?? .clear).cgColor
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.tag = 123_456
        
        if overlay {
            addSubview(borderView)
        } else {
            insertSubview(borderView, at: 0)
        }
        
        borderView.configure(with: style)
        
        return borderView
    }
    
    func removeAllStyles() {
        for subView in subviews where tag == 123_456 {
            subView.removeConstraints(subView.constraints)
            subView.removeFromSuperview()
        }
    }
    
    func addItemsSeparator() {
        applyStyle(.bottomBorder(insets: UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: -20.0), cornerRadius: 0.0, height: 0.8),
                   fillColor: .gray,
                   strokeColor: UIColor.clear,
                   overlay: false)
    }
    
    func removeLayersWithName(_ name: String) {
        
        guard let layers = layer.sublayers else {
            return
        }
        
        for layer in layers where name == name {
            layer.removeFromSuperlayer()
        }
    }
    
    func addCircularMaskWithBorder(_ border: Bool) {
        
        removeLayersWithName("cm_sublayer_layer")
        
        let circle = CAShapeLayer()
        let circularPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: max(frame.size.width, frame.size.height))
        circle.path = circularPath.cgPath
        circle.fillColor = UIColor.black.cgColor
        circle.strokeColor = UIColor.black.cgColor
        circle.lineWidth = 0.0
        
        layer.mask = circle
        
        let fram = bounds.insetBy(dx: 0.5, dy: 0.5)
        let strokePath = UIBezierPath(roundedRect: fram,
                                      cornerRadius: max(fram.size.width, fram.size.height))
        
        let strokeLayer = CAShapeLayer()
        strokeLayer.path = strokePath.cgPath
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = border ? UIColor.white.cgColor : UIColor.clear.cgColor
        strokeLayer.lineWidth = 1.0
        strokeLayer.name = "cm_sublayer_layer"
        
        layer.mask = circle
        
        layer.addSublayer(strokeLayer)
    }
    
    func applyShadow(with color: UIColor = .black, alpha: Float = 0.3, path: UIBezierPath? = nil) {
        isOpaque = false
        clipsToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowPath = path?.cgPath
    }
}
