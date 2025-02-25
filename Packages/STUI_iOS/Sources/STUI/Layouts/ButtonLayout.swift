//
//  Buttonlayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct Buttonlayout {
    
    let color: UIColor
    let selectedColor: UIColor?
    let backgroundColor: UIColor?
    let selectedBackgroundColor: UIColor?
    let selectedImage: UIImage?
    let image: UIImage?
    let cornerRadius: CGFloat?
    let borderColor: UIColor?
    let borderWith: CGFloat?
    let font: UIFont?
    let useDefaultLargeConfiguration: Bool
    let underlineText: Bool

    public init(color: UIColor,
                selectedColor: UIColor?,
                backgroundColor: UIColor?,
                selectedBackgroundColor: UIColor?,
                selectedImage: UIImage?,
                image: UIImage?,
                cornerRadius: CGFloat?,
                borderColor: UIColor?,
                borderWith: CGFloat?,
                font: UIFont?,
                useDefaultLargeConfiguration: Bool = true,
                underlineText: Bool = false) {
        self.color = color
        self.selectedColor = selectedColor
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.selectedImage = selectedImage
        self.image = image
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWith = borderWith
        self.font = font
        self.useDefaultLargeConfiguration = useDefaultLargeConfiguration
        self.underlineText = underlineText
    }
    
}

public extension Buttonlayout {
    
    func apply(to button: UIButton, text: String? = nil) {

        if let text = text {
            if underlineText {
                let attrs: [NSAttributedString.Key: Any] = [
                      .font: font as Any,
                      .underlineStyle: NSUnderlineStyle.single.rawValue
                  ]

                let attributeString = NSMutableAttributedString(
                        string: text,
                        attributes: attrs
                     )
                button.setAttributedTitle(attributeString, for: .normal)
            } else {
                let attrs: [NSAttributedString.Key: Any] = [
                      .font: font as Any,
                  ]

                let attributeString = NSMutableAttributedString(
                        string: text,
                        attributes: attrs
                     )
                button.setAttributedTitle(attributeString, for: .normal)
            }
        }

        if #available(iOS 15, *) {
            var configuration = backgroundColor != nil ? UIButton.Configuration.filled() : UIButton.Configuration.plain()
            configuration.baseForegroundColor = color
            
            var background = UIButton.Configuration.plain().background
            
            background.cornerRadius = cornerRadius ?? 0.0
            background.strokeWidth = borderWith ?? 0.0
            background.strokeColor = borderColor ?? .clear
            
            configuration.background = background
            
            if let backgroundColor = backgroundColor {
                configuration.baseBackgroundColor = backgroundColor
            }
            
            if useDefaultLargeConfiguration {
                configuration.buttonSize = .large
            }

            if underlineText {
                let attrs: [NSAttributedString.Key: Any] = [
                      .font: font as Any,
                      .underlineStyle: NSUnderlineStyle.single.rawValue
                  ]

                let attributeString = NSMutableAttributedString(
                        string: text ?? "",
                        attributes: attrs
                     )
                button.setAttributedTitle(attributeString, for: .normal)
            } else {
                var attText = AttributedString(text ?? "")
                attText.font = font
                configuration.attributedTitle = attText
            }

            configuration.image = image
            
            let handler: UIButton.ConfigurationUpdateHandler = { button in
                switch button.state {
                case .selected:
                    if let selectedBackgroundColor = selectedBackgroundColor {
                        button.configuration?.baseBackgroundColor = selectedBackgroundColor
                    }
                    button.configuration?.image = selectedImage
                default:
                    if let backgroundColor = backgroundColor {
                        button.configuration?.baseBackgroundColor = backgroundColor
                    }
                    button.configuration?.image = image
                }
            }
            
            button.configurationUpdateHandler = handler

            button.configuration = configuration

            return
        }
            
        button.setTitleColor(color, for: .normal)
        
        if let selectedColor = selectedColor {
            button.setTitleColor(selectedColor, for: .highlighted)
            button.setTitleColor(selectedColor, for: .selected)
        }
        
        if let backgroundColor = backgroundColor {
            button.setBackgroundImage(UIImage(color: backgroundColor), for: .normal)
        }
        
        if let selectedBackgroundColor = selectedBackgroundColor {
            button.setBackgroundImage(UIImage(color: selectedBackgroundColor), for: .highlighted)
            button.setBackgroundImage(UIImage(color: selectedBackgroundColor), for: .selected)
        }
        
        if let cornerRadius = cornerRadius {
            button.clipsToBounds = true
            button.layer.cornerRadius = cornerRadius
        }
        
        if let borderWith = borderWith {
            button.layer.borderWidth = borderWith
        }
        
        if let borderColor = borderColor {
            button.layer.borderColor = borderColor.cgColor
        }

        if let font = font {
            button.titleLabel?.font = font
        }

        button.setImage(selectedImage, for: .selected)
        button.setImage(image, for: .normal)
        
    }

    func changeBackgroudColor(backgroundColor: UIColor?) -> Buttonlayout {
        return Buttonlayout(color: self.color,
                            selectedColor: selectedColor,
                            backgroundColor: backgroundColor,
                            selectedBackgroundColor: selectedBackgroundColor,
                            selectedImage: selectedImage,
                            image: image,
                            cornerRadius: cornerRadius,
                            borderColor: borderColor,
                            borderWith: borderWith,
                            font: font)
    }
    
}
