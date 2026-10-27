//
//  SUISTToolbar.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

// MARK: - Internal styling
struct AdaptiveToolbarButtonStyle: ViewModifier {
    
    var iOS26Tint: Color = SUIColorLayout.primary.color
    var legacyTint: Color = SUIColorLayout.toolbarLegacyWhiteColor.color

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.tint(iOS26Tint)
        } else {
            content
                .buttonStyle(.plain)
                .tint(legacyTint)
                .foregroundStyle(legacyTint)
        }
    }
}

// MARK: - Toolbar button icon / Toolbar generic text
public struct STToolbarButton<Label: View>: View {
    private let action: () -> Void
    private let label: () -> Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action, label: label)
            .modifier(AdaptiveToolbarButtonStyle())
    }
}

// MARK: - Toolbar Menu
public struct STToolbarMenu<Label: View, Content: View>: View {
    private let label: () -> Label
    private let content: () -> Content

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
    }

    public var body: some View {
        Menu(content: content, label: label)
            .modifier(AdaptiveToolbarButtonStyle())
    }
}

// MARK: - Toolbar Edit Button
public struct STToolbarEditButton: View {
    public init() {}

    public var body: some View {
        EditButton()
            .modifier(AdaptiveToolbarButtonStyle())
    }
}
