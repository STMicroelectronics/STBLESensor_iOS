//
//  Buttonlayout+Profiling.swift
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

extension Buttonlayout {
    static func checkLayout(checkedImage: UIImage?, uncheckedImage: UIImage?) -> Buttonlayout {
        return Buttonlayout(color: ColorLayout.primary.auto,
                            selectedColor: ColorLayout.primary.auto,
                            backgroundColor: .clear,
                            selectedBackgroundColor: .clear,
                            selectedImage: checkedImage,
                            image: uncheckedImage,
                            cornerRadius: nil,
                            borderColor: .clear,
                            borderWith: nil,
                            font: FontLayout.regular)
    }
}
