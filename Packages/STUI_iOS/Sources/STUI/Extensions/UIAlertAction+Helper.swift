//
//  UIAlertAction+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STCore

public extension UIAlertAction {
    static func genericButton(_ title: String = Localizer.Common.ok.localized, _ action: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: title, style: .default, handler: action)
    }

    static func destructiveButton(_ title: String = Localizer.Common.ok.localized, _ action: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: title, style: .destructive, handler: action)
    }

    static func cancelButton(_ title: String = Localizer.Common.cancel.localized, _ action: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: title, style: .cancel, handler: action)
    }
}
