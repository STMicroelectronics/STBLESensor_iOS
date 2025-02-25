//
//  TextInputLayout.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit


public struct TextInputLayout {
    
    let keyboardType: UIKeyboardType
    
    public init(keyboardType: UIKeyboardType = .default) {
        self.keyboardType = keyboardType
    }
}

public extension TextInputLayout {
    
    func apply(to textField: UITextField) {
        textField.setDimensionContraints(width: nil, height: 44)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.keyboardType = self.keyboardType
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = ColorLayout.stGray5.light.cgColor
        textField.returnKeyType = .done
    }
}
