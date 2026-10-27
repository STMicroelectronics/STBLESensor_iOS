//
//  SUITextInputLayout.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public struct SUITextInputLayout {
    let keyboardType: UIKeyboardType
    let height: CGFloat = 44
    let cornerRadius: CGFloat = 5
    let borderColor: Color = SUIColorLayout.stGray5.color
    
    public init(keyboardType: UIKeyboardType = .default) {
        self.keyboardType = keyboardType
    }
}

struct SUITextInputModifier: ViewModifier {
    let layout: SUITextInputLayout

    func body(content: Content) -> some View {
        content
            .keyboardType(layout.keyboardType)
            .submitLabel(.done)
            .padding(.horizontal, 15)
            .frame(height: layout.height)
            .background(Color(.systemBackground))
            .cornerRadius(layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: layout.cornerRadius)
                    .stroke(layout.borderColor, lineWidth: 1)
            )
    }
}

public extension View {
    func applyTextInputLayout(_ layout: SUITextInputLayout) -> some View {
        self.modifier(SUITextInputModifier(layout: layout))
    }
}
