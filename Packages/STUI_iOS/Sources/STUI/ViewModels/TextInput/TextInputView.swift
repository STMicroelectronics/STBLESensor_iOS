//
//  TextInputView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class TextInputView: UIView {
    var stackView = UIStackView()

    let titleLabel = UILabel()
    let textField = UITextField()

    var handleChangeText: ((String) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .horizontal
        stackView.spacing = 20.0

        addSubviewAndFit(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)

        stackView.activate(constraints: [
            equalDimension(\.heightAnchor, to: 40.0)
        ])

        titleLabel.numberOfLines = 2
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true

        titleLabel.activate(constraints: [
            equalDimension(\.widthAnchor, to: 100.0)
        ])

        textField.borderStyle = .roundedRect
        textField.delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TextInputView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        guard let handleChangeText = handleChangeText,
              let text = textField.text else { return false }

        handleChangeText(text)
        return true
    }
}

