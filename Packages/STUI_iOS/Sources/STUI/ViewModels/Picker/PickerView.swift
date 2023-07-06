//
//  PickerView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class PickerView: UIView {
    var stackView = UIStackView()

    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let actionButton = UIButton()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .horizontal
        stackView.spacing = 20.0

        actionButton.setImage(ImageLayout.Common.chevronDown, for: .normal)

        addSubviewAndFit(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(actionButton)

        stackView.activate(constraints: [
            equalDimension(\.heightAnchor, to: 40.0)
        ])

        actionButton.activate(constraints: [
            equalDimension(\.widthAnchor, to: 40.0)
        ])
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
