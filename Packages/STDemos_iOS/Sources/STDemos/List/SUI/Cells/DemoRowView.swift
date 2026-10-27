//
//  DemoRowView.swift
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
import STBlueSDK

public struct DemoRowView: View {

    let demo: Demo
    let index: Int
    let isLockedCheckEnabled: Bool

    public init(
        demo: Demo,
        index: Int,
        isLockedCheckEnabled: Bool = false
    ) {
        self.demo = demo
        self.index = index
        self.isLockedCheckEnabled = isLockedCheckEnabled
    }

    private var isLocked: Bool {

        guard isLockedCheckEnabled else {
            return false
        }

        return demo.isLocked || demo.isLockedForNotExpert
    }

    private var imageBackgroundColor: Color {
        index.isMultiple(of: 2)
        ? SUIColorLayout.secondary.color
        : SUIColorLayout.yellow.color
    }

    public var body: some View {

        HStack(spacing: 10) {

            imageSection

            textSection

            if isLocked {
                lockSection
            }
        }
        .frame(height: 85)
        .padding(.horizontal, 20)
//        .padding(.vertical, 10)
        .opacity(isLocked ? 0.4 : 1.0)
    }
}

private extension DemoRowView {

    var imageSection: some View {

        ZStack {

            imageBackgroundColor

            demo.suiImage
                .resizable()
                .scaledToFit()
                .padding(8)
            
        }
        .frame(width: 85, height: 85)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
    }
}

private extension DemoRowView {

    var textSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(demo.title)
                .applyTextLayout(.title2).fontWeight(.semibold)

            Text(demo.description)
                .applyTextLayout(.info)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private extension DemoRowView {

    @ViewBuilder
    var lockSection: some View {
        SUIImageLayout.Common.lock
            .frame(width: 60)
    }
}
