//
//  SUITextLayout+ST.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public extension SUITextLayout {
    
    // MARK: - Static Text Layouts
    static let title = SUITextLayout(
        color: SUIColorLayout.systemBlack.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .stTitle
    )

    static let largetitle = SUITextLayout(
        color: SUIColorLayout.primary.color,
        alignment: .center,
        numberOfLines: 0,
        font: .system(size: 34.0)
    )

    static let subtitle = SUITextLayout(
        color: SUIColorLayout.text.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .stSubtitle
    )

    static let text = SUITextLayout(
        color: SUIColorLayout.text.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .stRegular
    )

    static let info = SUITextLayout(
        color: SUIColorLayout.text.dark,
        alignment: .leading,
        numberOfLines: 0,
        font: .system(size: 13.0, weight: .light)
    )

    static let infoBold = SUITextLayout(
        color: SUIColorLayout.text.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .system(size: 13.0, weight: .bold)
    )

    static let tabItem = SUITextLayout(
        color: .white,
        alignment: .leading,
        numberOfLines: 0,
        font: .system(size: 14.0)
    )

    static let title2 = SUITextLayout(
        color: SUIColorLayout.primary.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .stBold
    )

    static let title3 = SUITextLayout(
        color: SUIColorLayout.primary.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .stSemiBold
    )
    
    static let bold = SUITextLayout(
        color: SUIColorLayout.primary.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .system(size: 17.0, weight: .bold)
    )

    static let accent = SUITextLayout(
        color: SUIColorLayout.accent.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .stRegular
    )

    static let accentBold = SUITextLayout(
        color: SUIColorLayout.accent.color,
        alignment: .leading,
        numberOfLines: 0,
        font: .system(size: 17.0, weight: .bold)
    )

    // MARK: - Dynamic Text Layouts
    static func title2Colored(_ definedColor: Color) -> SUITextLayout {
        SUITextLayout(
            color: definedColor,
            alignment: .leading,
            numberOfLines: 0,
            font: .system(size: 20.0, weight: .bold)
        )
    }

    static func infoBoldColored(_ definedColor: Color) -> SUITextLayout {
        SUITextLayout(
            color: definedColor,
            alignment: .leading,
            numberOfLines: 0,
            font: .system(size: 13.0, weight: .bold)
        )
    }

    static func infoColored(_ definedColor: Color) -> SUITextLayout {
        SUITextLayout(
            color: definedColor,
            alignment: .leading,
            numberOfLines: 0,
            font: .system(size: 13.0, weight: .light)
        )
    }
}
