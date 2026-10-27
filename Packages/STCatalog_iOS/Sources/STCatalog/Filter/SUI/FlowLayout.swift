//
//  FlowLayout.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

@available(iOS 16.0, *)
public struct FlowLayout: Layout {

    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {

        let maxWidth = proposal.width ?? .infinity

        var width: CGFloat = 0
        var height: CGFloat = 0

        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for subview in subviews {

            let size = subview.sizeThatFits(.unspecified)

            if currentRowWidth + size.width > maxWidth {

                width = max(width, currentRowWidth)

                height += currentRowHeight + spacing

                currentRowWidth = size.width + spacing
                currentRowHeight = size.height

            } else {

                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }

        width = max(width, currentRowWidth)
        height += currentRowHeight

        return CGSize(width: width, height: height)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {

        var point = CGPoint(x: bounds.minX,
                            y: bounds.minY)

        var currentRowHeight: CGFloat = 0

        for subview in subviews {

            let size = subview.sizeThatFits(.unspecified)

            if point.x + size.width > bounds.maxX {

                point.x = bounds.minX
                point.y += currentRowHeight + spacing
                currentRowHeight = 0
            }

            subview.place(
                at: point,
                proposal: ProposedViewSize(size)
            )

            point.x += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}
