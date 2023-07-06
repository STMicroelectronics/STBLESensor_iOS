//
//  Option.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit

public class Option {
    public let title: String
    public let subtitle: String?
    public let content: String?
    public let checkedImage: UIImage?
    public let uncheckedImage: UIImage?
    public let image: UIImage?
    public var isSelected: Bool
    
    public init(title: String,
                subtitle: String?,
                content: String?,
                checkedImage: UIImage?,
                uncheckedImage: UIImage?,
                image: UIImage?,
                isSelected: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.checkedImage = checkedImage
        self.uncheckedImage = uncheckedImage
        self.image = image
        self.isSelected = isSelected
    }
}
