//
//  LabelView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class LabelView: UIView {
    let textLabel = UILabel()
    let actionImageView = UIImageView()
    let actionButton = UIButton(type: .custom)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView()
        stackView.spacing = 5.0
        stackView.axis = .horizontal

        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(actionImageView)

        addSubviewAndFit(stackView)
        addSubviewAndFit(actionButton)

        actionImageView.activate(constraints: [
            equalDimension(\.widthAnchor, to: 30.0)
        ])

        textLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
