//
//  Localizer+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

extension RawRepresentable where RawValue == String, Self: Localizable {

    internal var localized: String {
        localized(in: .module)
    }

    internal func localized(with arguments: [ CVarArg ]? = nil) -> String {
        localized(with: arguments, in: .module)
    }
}

extension String {
    internal var localized: String {
        localized(in: .module)
    }

    internal func localized(with arguments: [ CVarArg ]? = nil) -> String {
        localized(with: arguments, in: .module)
    }
}
