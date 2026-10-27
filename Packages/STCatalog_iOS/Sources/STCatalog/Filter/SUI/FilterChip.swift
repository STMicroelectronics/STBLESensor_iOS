//
//  FilterChip.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI

struct FilterChip: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
            
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                .foregroundColor(SUIColorLayout.primary.color)

                .background(
                    isSelected
                    ? SUIColorLayout.secondary.color
                    : SUIColorLayout.stGray1.color.opacity(0.15)
                )

                .applyTextLayout(.text)
            
                .overlay {

                    Capsule()
                        .stroke(
                            isSelected
                            ? SUIColorLayout.primary.color
                            : SUIColorLayout.stGray1.color.opacity(0.4),
                            lineWidth: 1
                        )
                }

                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
