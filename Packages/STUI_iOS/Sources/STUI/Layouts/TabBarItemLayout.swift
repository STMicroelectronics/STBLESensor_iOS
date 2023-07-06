//
//  TabBarItemLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct TabBarItemLayout {

    var text: String?
    var font: UIFont
    var textColor: UIColor
    var selectedTextColor: UIColor
    var image: UIImage?
    var selectedImage: UIImage?

    public init(text: String? = nil,
                font: UIFont,
                textColor: UIColor,
                selectedTextColor: UIColor,
                image: UIImage?,
                selectedImage: UIImage?) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.image = image
        self.selectedImage = selectedImage
    }
}

public extension UITabBarItem {
    static func item(withLayout layout: TabBarItemLayout) -> UITabBarItem {

        let item = UITabBarItem(title: layout.text, image: layout.image, selectedImage: layout.selectedImage)

        item.setTitleTextAttributes([
            .foregroundColor: layout.textColor,
            .font: layout.font
        ], for: .normal)

        item.setTitleTextAttributes([
            .foregroundColor: layout.selectedTextColor
        ], for: .selected)

        return item
    }
}
