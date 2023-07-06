//
//  TabBarItemLayout+ST.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

extension TabBarItemLayout {
    static var main: TabBarItemLayout = {
        TabBarItemLayout(text: "Main",
                         font: FontLayout.tabItem,
                         textColor: ColorLayout.text.light,
                         selectedTextColor: ColorLayout.primary.auto,
                         image: nil,
                         selectedImage: nil)
    }()

    static var catalog: TabBarItemLayout = {
        TabBarItemLayout(text: "Catalog",
                         font: FontLayout.tabItem,
                         textColor: ColorLayout.text.light,
                         selectedTextColor: ColorLayout.primary.auto,
                         image: nil,
                         selectedImage: nil)
    }()

    static var filter: TabBarItemLayout = {
        TabBarItemLayout(text: "Filter",
                         font: FontLayout.tabItem,
                         textColor: ColorLayout.text.light,
                         selectedTextColor: ColorLayout.primary.auto,
                         image: nil,
                         selectedImage: nil)
    }()
}
