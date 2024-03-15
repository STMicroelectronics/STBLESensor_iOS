//
//  Buttonlayout+ST.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension Buttonlayout {
    
    static var standard: Buttonlayout = {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.primary.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular)
    }()
    
    static var standardWithSmallFont: Buttonlayout = {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.primary.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(12.0))
    }()

    static var standardLight: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.primary.light,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.secondary.light,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular)
    }()

    static var standardAccent: Buttonlayout = {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.accent.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(14.0))
    }()

    static var standardGray: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.accent.auto,
                            selectedColor: nil,
                            backgroundColor: .systemGray6,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(14.0))
    }()
    
    static var standardRed: Buttonlayout = {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.red.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(14.0))
    }()
    
    static var standardGreen: Buttonlayout = {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.green.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(14.0))
    }()
    
    static var standardYellow: Buttonlayout = {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.yellow.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(14.0))
    }()
    
    static var lightBlueSecondary: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.primary.auto,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.lightBlue.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(14.0))
    }()
    
    static var rounded: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.primary.dark,
                            selectedColor: nil,
                            backgroundColor: .white,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: 10.0,
                            borderColor: ColorLayout.primary.dark,
                            borderWith: 1.0,
                            font: FontLayout.regular)
    }()
    
    static var clear: Buttonlayout = {
        return Buttonlayout(color: .clear,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular)
    }()

    static var text: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.accent.auto,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(12.0))
    }()

    static var link: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.primary.auto,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.bold.withSize(20.0),
                            underlineText: true)
    }()

    static var textPrimaryColor: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.primary.auto,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(12.0))
    }()
    
    static var textSecondaryColor: Buttonlayout = {
        return Buttonlayout(color: ColorLayout.secondary.auto,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: nil,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular.withSize(12.0),
                            useDefaultLargeConfiguration: false)
    }()

    static func imageLayout(image: UIImage?, selectedImage: UIImage?, color: UIColor) -> Buttonlayout {
        return Buttonlayout(color: color,
                            selectedColor: color,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: selectedImage,
                            image: image,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular)
    }
    
    static func standardWithImage(image: UIImage?) -> Buttonlayout {
        return Buttonlayout(color: .white,
                            selectedColor: nil,
                            backgroundColor: ColorLayout.primary.auto,
                            selectedBackgroundColor: nil,
                            selectedImage: nil,
                            image: image,
                            cornerRadius: 4.0,
                            borderColor: nil,
                            borderWith: nil,
                            font: FontLayout.regular)
    }
    
    static func imageCleared(image: UIImage?) -> Buttonlayout {
        return Buttonlayout(color: .clear,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: image,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular)
    }
    
    static func textColorWithIamge(color: UIColor?, image: UIImage?) -> Buttonlayout {
        return Buttonlayout(color: color ?? ColorLayout.primary.auto,
                            selectedColor: .clear,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: nil,
                            image: image,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular)
    }
}
