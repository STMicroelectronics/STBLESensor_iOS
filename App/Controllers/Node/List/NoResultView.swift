//
//  NoResultView.swift
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

class NoResultView: UIView {
    let stackView = UIStackView()

    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let actionButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .vertical
        stackView.spacing = 10.0

        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20),
            equal(\.trailingAnchor, constant: -20),
            equal(\.centerYAnchor)
        ])

        imageView.contentMode = .scaleAspectFit

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(actionButton)

        TextLayout.title.alignment(.center).apply(to: titleLabel)
        TextLayout.info.alignment(.center).apply(to: descriptionLabel)

        Buttonlayout.standard.apply(to: actionButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
