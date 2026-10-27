//
//  SUIFontLayout+ST.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public extension Font {
    static var stTitle: Font            { .system(size: 30.0) }
    static var stRegular: Font          { .system(size: 15.0, weight: .regular) }
    static var stRegularBigFont: Font   { .system(size: 18.0, weight: .regular) }
    static var stRegularSmallFont: Font { .system(size: 12.0, weight: .regular) }
    static var stBold: Font             { .system(size: 19.0, weight: .bold) }
    static var stSemiBold: Font         { .system(size: 17.0, weight: .semibold) }
    static var stBoldSmallFont: Font    { .system(size: 12.0, weight: .bold) }
    static var stTitle2: Font           { .system(size: 19.0, weight: .bold) }
    static var stInfo: Font             { .system(size: 13.0, weight: .light) }
    static var stInfoBold: Font         { .system(size: 13.0, weight: .bold) }
    
    static var stSubtitle: Font   { .system(size: 14.0) }
    static var stTabItem: Font    { .system(size: 14.0) }
    
    static func stRelative(_ rel: CGFloat, weight: Font.Weight = .regular) -> Font {
        SUIFontLayout.font(rel: rel, weight: weight)
    }
}
