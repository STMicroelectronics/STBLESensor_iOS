//
//  RSSIView.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

class RSSIView: UIView {

    let stackView = UIStackView()

    let rssiLabel = UILabel()
    let rssiImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        TextLayout.info.apply(to: rssiLabel)

        rssiImageView.contentMode = .scaleAspectFit
        rssiImageView.image = ImageLayout.image(with: "img_signal_bars")

        rssiImageView.setDimensionContraints(width: 80.0)

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                     views: [
                                                                        rssiImageView,
                                                                        UIView(),
                                                                        rssiLabel
                                                                     ])

        horizontalStackView.distribution = .fill

        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
        ])

        stackView.setDimensionContraints(height: 80.0)

        stackView.addArrangedSubview(horizontalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
