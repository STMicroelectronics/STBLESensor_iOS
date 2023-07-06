//
//  ButtonView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class ButtonView: UIView {
    var stackView = UIStackView()

    let actionButton = UIButton()
    let leftEmptyView = UIView()
    let rightEmptyView = UIView()

    var handleButtonTouched: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .horizontal
        stackView.spacing = 20.0

        addSubviewAndFit(stackView)

        stackView.addArrangedSubview(leftEmptyView)
        stackView.addArrangedSubview(actionButton)
        stackView.addArrangedSubview(rightEmptyView)

        actionButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self, let handleButtonTouched = self.handleButtonTouched else { return }
            handleButtonTouched()
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
