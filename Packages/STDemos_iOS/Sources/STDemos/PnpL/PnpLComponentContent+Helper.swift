//
//  PnpLComponentContent+helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

public extension PnpLComponentContent {

    var compoundName: String {
        if schema.contains("sensors") {
            return localizedName ?? "Unknown"
        } else  {
            return displayName?.en ?? "Unknown"
        }
    }

    var compoundSubtile: String {
        if schema.contains("sensors") {
            return String(name.split(separator: "_").first ?? "Unknown")
        } else {
            return ""
        }
    }

    var icon: UIImage? {
        if schema.contains("sensors") {
            return ImageLayout
                .image(with: PnPLType.type(with: name).iconName, in: STDemos.bundle)?
                .maskWithColor(color: ColorLayout.secondary.light)
        } else {
            return ImageLayout
                .image(with: "ic_info", in: STDemos.bundle)?
                .maskWithColor(color: ColorLayout.secondary.light)
        }
    }
    
}

private extension PnpLComponentContent {
    var localizedName: String? {
        guard let key = PnPLType.type(with: name).nameKey else { return nil }
        return NSLocalizedString(key, bundle: .module, comment: "")
    }
}
