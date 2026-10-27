//
//  ProfilingOptionView.swift
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

public struct ProfilingOptionView: View {
    @ObservedObject public var option: Option
    public let onSelect: () -> Void

    public init(option: Option, onSelect: @escaping () -> Void) {
        self.option = option
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 16) {
                if let image = option.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(4)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .applyTextLayout(.title2)
                        .multilineTextAlignment(.leading)

                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .applyTextLayout(.info)
                            .multilineTextAlignment(.leading)
                        
                    }
                }
                
                Spacer(minLength: 10)

                Group {
                    if option.isSelected {
                        (option.checkedImage ?? Image(systemName: "checkmark.circle.fill"))
                            .foregroundColor(SUIColorLayout.primary.color)
                    } else {
                        (option.uncheckedImage ?? Image(systemName: "circle"))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                .font(.system(size: 22))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
