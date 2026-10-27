//
//  SUITextInputLayout+ST.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public extension SUITextInputLayout {
    static let standard     = SUITextInputLayout(keyboardType: .default)
    static let numerical    = SUITextInputLayout(keyboardType: .numberPad)
    static let decimal      = SUITextInputLayout(keyboardType: .decimalPad)
    static let emailAddress = SUITextInputLayout(keyboardType: .emailAddress)
    static let url          = SUITextInputLayout(keyboardType: .URL)
}
