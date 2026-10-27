//
//  SUIButtonLayout.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public struct STButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled
    
    let layout: SUIButtonlayout

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            if let img = (configuration.isPressed ? (layout.selectedImage ?? layout.image) : layout.image) {
                img
            }
            
            configuration.label
        }
        .font(layout.font)
        .foregroundColor(isEnabled ? layout.textColor : SUIColorLayout.stGray3.color)
        .padding(.vertical, 14)
        .padding(.horizontal, 32)
        .frame(maxWidth: layout.fullWidth ? .infinity : nil)
        .background(
            (isEnabled ? layout.backgroundColor : SUIColorLayout.stGray5.color)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
        )
        .cornerRadius(layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: layout.cornerRadius)
                .stroke(layout.borderColor, lineWidth: layout.borderWidth)
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

public struct SUIButtonlayout {
    let textColor: Color
    let backgroundColor: Color
    let font: Font
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let fullWidth: Bool
    let image: Image?
    let selectedImage: Image?
    
    public init(textColor: Color,
                backgroundColor: Color,
                font: Font,
                cornerRadius: CGFloat,
                borderColor: Color,
                borderWidth: CGFloat,
                fullWidth: Bool,
                image: Image?,
                selectedImage: Image?) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.fullWidth = fullWidth
        self.image = image
        self.selectedImage = selectedImage
    }
}

public extension SUIButtonlayout {
    func with(fullWidth: Bool) -> SUIButtonlayout {
        SUIButtonlayout(
            textColor: self.textColor,
            backgroundColor: self.backgroundColor,
            font: self.font,
            cornerRadius: self.cornerRadius,
            borderColor: self.borderColor,
            borderWidth: self.borderWidth,
            fullWidth: fullWidth,
            image: self.image,
            selectedImage: self.selectedImage
        )
    }
}

extension View {
    public func applyButtonLayout(_ layout: SUIButtonlayout) -> some View {
        self.buttonStyle(STButtonStyle(layout: layout))
    }
}
