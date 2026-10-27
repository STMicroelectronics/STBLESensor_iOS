//
//  SUITextLayout.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public struct SUITextLayout {
    public var color: Color
    public var backgroundColor: Color
    public var cornerRadius: CGFloat
    public var borderColor: Color
    public var borderWidth: CGFloat
    public var alignment: TextAlignment
    public var numberOfLines: Int?
    public var font: Font

    public init(
        color: Color = .primary,
        backgroundColor: Color = .clear,
        cornerRadius: CGFloat = 0,
        borderColor: Color = .clear,
        borderWidth: CGFloat = 0,
        alignment: TextAlignment = .leading,
        numberOfLines: Int? = nil,
        font: Font = .body
    ) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.alignment = alignment
        self.numberOfLines = numberOfLines
        self.font = font
    }
}

// MARK: - Chainable Methods
public extension SUITextLayout {
    func color(_ newColor: Color) -> SUITextLayout {
        var copy = self
        copy.color = newColor
        return copy
    }

    func alignment(_ newAlign: TextAlignment) -> SUITextLayout {
        var copy = self
        copy.alignment = newAlign
        return copy
    }
    
    func font(_ newFont: Font) -> SUITextLayout {
        var copy = self
        copy.font = newFont
        return copy
    }
}

// MARK: - View Extension
public extension View {
    func applyTextLayout(_ layout: SUITextLayout) -> some View {
        self.modifier(SUITextLayoutModifier(layout: layout))
    }
}

struct SUITextLayoutModifier: ViewModifier {
    let layout: SUITextLayout

    func body(content: Content) -> some View {
        content
            .font(layout.font)
            .foregroundColor(layout.color)
            .multilineTextAlignment(layout.alignment)
            .lineLimit(layout.numberOfLines == 0 ? nil : layout.numberOfLines)
            .fixedSize(horizontal: false, vertical: layout.numberOfLines == nil || layout.numberOfLines == 0)
            .padding(layout.backgroundColor != .clear ? 8 : 0)
            .background(layout.backgroundColor)
            .cornerRadius(layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: layout.cornerRadius)
                    .stroke(layout.borderColor, lineWidth: layout.borderWidth)
            )
    }
}
