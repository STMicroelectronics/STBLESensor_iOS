//
//  TextInputLayout+ST.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation


public extension TextInputLayout {
    
    static let standard: TextInputLayout = {
        return TextInputLayout(keyboardType: .default)
    }()
    
    static let numerical: TextInputLayout = {
        return TextInputLayout(keyboardType: .numberPad)
    }()
    
    static let decimal: TextInputLayout = {
        return TextInputLayout(keyboardType: .decimalPad)
    }()
    
    static let emailAddress: TextInputLayout = {
        return TextInputLayout(keyboardType: .emailAddress)
    }()
    
    static let url: TextInputLayout = {
        return TextInputLayout(keyboardType: .URL)
    }()
}
