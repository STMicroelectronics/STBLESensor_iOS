//
//  NavigationLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct NavigationLayout {
    public let tintColor: UIColor?
    public let barTintColor: UIColor?
    public let titleTextColor: UIColor?
    public let titleTextFont: UIFont?
    public let isTranslucent: Bool?
    public let logoImage: UIImage?
    public let backgroundImage: UIImage?
    public let shadowImage: UIImage?
    public let navigationBarHidden: Bool
    public let statusBarStyle: UIStatusBarStyle
    public let statusBarHidden: Bool
    public let noShadow: Bool

    public init(tintColor: UIColor? = nil,
                barTintColor: UIColor? = nil,
                titleTextColor: UIColor? = nil,
                titleTextFont: UIFont? = nil,
                isTranslucent: Bool? = nil,
                logoImage: UIImage? = nil,
                backgroundImage: UIImage? = nil,
                shadowImage: UIImage? = nil,
                navigationBarHidden: Bool = false,
                statusBarStyle: UIStatusBarStyle = .default,
                statusBarHidden: Bool = false,
                noShadow: Bool = false) {
        self.tintColor = tintColor
        self.barTintColor = barTintColor
        self.titleTextColor = titleTextColor
        self.titleTextFont = titleTextFont
        self.isTranslucent = isTranslucent
        self.logoImage = logoImage
        self.backgroundImage = backgroundImage
        self.shadowImage = shadowImage
        self.navigationBarHidden = navigationBarHidden
        self.statusBarStyle = statusBarStyle
        self.statusBarHidden = statusBarHidden
        self.noShadow = noShadow
    }

    public func apply() {
        if #available(iOS 15, *) {

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance

            if let image = backgroundImage {
                appearance.backgroundImage = image
            }

            if let image = shadowImage {
                appearance.shadowImage = image
            }

            if noShadow {
                appearance.shadowImage = nil
                appearance.backgroundImage = nil
            }

            if let titleColor = titleTextColor,
                let font = titleTextFont {
                var attributes = [NSAttributedString.Key: Any]()
                attributes[NSAttributedString.Key.foregroundColor] = titleColor
                attributes[NSAttributedString.Key.font] = font

                appearance.titleTextAttributes = attributes
            }


            if let color = tintColor {
                UIBarButtonItem.appearance().tintColor = color
            }

            if let color = barTintColor {
                appearance.backgroundColor = color
            }

            return
        }
    }

    public func applyTo(navBar: UINavigationBar?, navItem: UINavigationItem?) {

        guard let navBar = navBar,
        let navItem = navItem else {
            apply()
            return
        }

        if let image = logoImage {
            let imageView: UIImageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image.original
            imageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            navItem.titleView = imageView
        } else {
            navItem.titleView = nil
        }

        if let image = backgroundImage {
            navBar.setBackgroundImage(image, for: .any, barMetrics: .default)
        }

        if let image = shadowImage {
            navBar.shadowImage = image
        }

        if noShadow {
            navBar.shadowImage = nil
            navBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        }

        if let titleColor = titleTextColor, let font = titleTextFont {
            var attributes = navBar.titleTextAttributes ?? [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.foregroundColor] = titleColor
            attributes[NSAttributedString.Key.font] = font
            navBar.titleTextAttributes = attributes
        }

        if let translucent = isTranslucent {
            navBar.isTranslucent = translucent
        }

        if let color = tintColor {
            navBar.tintColor = color
        }

        if let color = barTintColor {
            navBar.barTintColor = color
        }
    }
}
