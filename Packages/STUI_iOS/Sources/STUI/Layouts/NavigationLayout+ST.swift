//
//  NavigationLayout+ST.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension NavigationLayout {

    static var base = NavigationLayout(tintColor: .white,
                                       barTintColor: ColorLayout.primary.auto,
                                       titleTextColor: .white,
                                       titleTextFont: .systemFont(ofSize: 18.0),
                                       isTranslucent: false,
                                       backgroundImage: UIImage(color: ColorLayout.primary.auto),
                                       shadowImage: UIImage(color: UIColor.lightGray.withAlphaComponent(0.2)),
                                       navigationBarHidden: false,
                                       statusBarStyle: .lightContent,
                                       statusBarHidden: false)

    static var hidden = NavigationLayout(tintColor: .clear,
                                       barTintColor: .clear,
                                       titleTextColor: .clear,
                                       isTranslucent: false,
                                       backgroundImage: UIImage(color: .clear),
                                       shadowImage: nil,
                                       navigationBarHidden: true,
                                       statusBarStyle: .lightContent,
                                       statusBarHidden: false)
}
