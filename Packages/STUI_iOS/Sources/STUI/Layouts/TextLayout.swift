//
//  TextLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct TextLayout {
    
    let color: UIColor
    let backgroundColor: UIColor?
    let cornerRadius: CGFloat?
    let borderColor: UIColor?
    let borderWith: CGFloat?
    let alignment: NSTextAlignment?
    let numberOfLines: Int?
    let font: UIFont?
    
    public init(color: UIColor,
                backgroundColor: UIColor?,
                cornerRadius: CGFloat?,
                borderColor: UIColor?,
                borderWith: CGFloat?,
                alignment: NSTextAlignment?,
                numberOfLines: Int?,
                font: UIFont?) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWith = borderWith
        self.alignment = alignment
        self.numberOfLines = numberOfLines
        self.font = font
    }
    
}

public extension TextLayout {
    
    func apply(to label: UILabel) {
        
        label.textColor = color
        
        if let backgroundColor = backgroundColor {
            label.backgroundColor = backgroundColor
        }
        
        if let cornerRadius = cornerRadius {
            label.clipsToBounds = true
            label.layer.cornerRadius = cornerRadius
        }
        
        if let borderWith = borderWith {
            label.layer.borderWidth = borderWith
        }
        
        if let borderColor = borderColor {
            label.layer.borderColor = borderColor.cgColor
        }
        
        label.textAlignment = alignment ?? .center
        label.numberOfLines = numberOfLines ?? 0
        
        if let font = font {
            label.font = font
        }
        
    }
    
    func alignment(_ alignment: NSTextAlignment) -> TextLayout {
        
        return TextLayout(color: color,
                          backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          borderColor: borderColor,
                          borderWith: borderWith,
                          alignment: alignment,
                          numberOfLines: numberOfLines,
                          font: font)
    }
    
    func size(_ size: CGFloat) -> TextLayout {
        
        return TextLayout(color: color,
                          backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          borderColor: borderColor,
                          borderWith: borderWith,
                          alignment: alignment,
                          numberOfLines: numberOfLines,
                          font: self.font?.withSize(size))
    }
    
    func weight(_ weight: UIFont.Weight) -> TextLayout {
        return TextLayout(color: color,
                          backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          borderColor: borderColor,
                          borderWith: borderWith,
                          alignment: alignment,
                          numberOfLines: numberOfLines,
                          font: .systemFont(ofSize: self.font?.pointSize ?? 17.0,
                                            weight: weight))
    }
    
    func font(_ font: UIFont) -> TextLayout {
        
        return TextLayout(color: color,
                          backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          borderColor: borderColor,
                          borderWith: borderWith,
                          alignment: alignment,
                          numberOfLines: numberOfLines,
                          font: font)
    }
    
    func color(_ color: UIColor) -> TextLayout {
        
        return TextLayout(color: color,
                          backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          borderColor: borderColor,
                          borderWith: borderWith,
                          alignment: alignment,
                          numberOfLines: numberOfLines,
                          font: font)
    }

    func backgroundColor(_ backgroundColor: UIColor) -> TextLayout {

        return TextLayout(color: color,
                          backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          borderColor: borderColor,
                          borderWith: borderWith,
                          alignment: alignment,
                          numberOfLines: numberOfLines,
                          font: font)
    }
    
}
