//
//  SUIButtonLayout+ST.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public extension SUIButtonlayout {
    // MARK: - Static Button Layouts
    static var standard: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.primary.color,
            font: .stRegularBigFont,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardLight: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: SUIColorLayout.secondary.color,
            font: .stRegularBigFont,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardWithSmallFont: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.primary.color,
            font: .stRegularSmallFont,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: true,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardAccent: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.accent.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardRed: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.red.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardGreen: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.green.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardYellow: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.yellow.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardGray: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: SUIColorLayout.stGray6.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var standardGray7: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: SUIColorLayout.stGray7.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var lightBlueSecondary: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: SUIColorLayout.lightBlue.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var clear: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: .white,
            font: .stRegularBigFont,
            cornerRadius: 10.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var rounded: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: .white,
            font: .stRegularBigFont,
            cornerRadius: 10.0,
            borderColor: SUIColorLayout.primary.color,
            borderWidth: 1.0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var text: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.accent.color,
            backgroundColor: .clear,
            font: .stRegularSmallFont,
            cornerRadius: 0.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var link: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: .clear,
            font: .stBold,
            cornerRadius: 0.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var smallLink: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.secondary.color,
            backgroundColor: .clear,
            font: .stBoldSmallFont,
            cornerRadius: 0.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var textPrimaryColor: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.primary.color,
            backgroundColor: .clear,
            font: .stRegularSmallFont,
            cornerRadius: 0.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    static var textSecondaryColor: SUIButtonlayout {
        SUIButtonlayout(
            textColor: SUIColorLayout.secondary.color,
            backgroundColor: .clear,
            font: .stRegularSmallFont,
            cornerRadius: 0.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    
    static var smallSelected: SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.secondary.color,
            font: .stRegularSmallFont,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
    
    // MARK: - Dynamic Button Layouts
    static func imageLayout(image: Image?, selectedImage: Image?, color: Color) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: color,
            backgroundColor: .clear,
            font: .stRegular,
            cornerRadius: 0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: image,
            selectedImage: selectedImage
        )
    }
    
    static func standardWithImage(image: Image?) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: SUIColorLayout.primary.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: image,
            selectedImage: nil
        )
    }
    
    static func standardWithColorAndImage(textColor: Color?, buttonColor: Color?, image: Image?) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: textColor ?? SUIColorLayout.primary.color,
            backgroundColor: buttonColor ?? SUIColorLayout.primary.color,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: image,
            selectedImage: nil
        )
    }
    
    static func imageCleared(image: Image?) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: .clear,
            backgroundColor: .clear,
            font: .stRegular,
            cornerRadius: 0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: image,
            selectedImage: nil
        )
    }
    
    static func textColorWithImage(color: Color?, image: Image?) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: color ?? SUIColorLayout.primary.color,
            backgroundColor: .clear,
            font: .stRegular,
            cornerRadius: 0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: image,
            selectedImage: nil
        )
    }
    
    static func standardColored(_ definedColor: Color) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: .white,
            backgroundColor: definedColor,
            font: .stRegular,
            cornerRadius: 4.0,
            borderColor: .clear,
            borderWidth: 0,
            fullWidth: false,
            image: nil,
            selectedImage: nil
        )
    }
}
