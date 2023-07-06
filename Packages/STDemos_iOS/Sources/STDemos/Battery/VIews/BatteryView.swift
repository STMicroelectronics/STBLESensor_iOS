//
//  BatteryView.swift
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

class BatteryView: UIView {

    let stackView = UIStackView()
    let voltageLabel = UILabel()
    let chargeLabel = UILabel()
    let statusLabel = UILabel()
    let chargeImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        TextLayout.info.apply(to: voltageLabel)
        TextLayout.info.apply(to: statusLabel)
        TextLayout.info.apply(to: chargeLabel)

        chargeImageView.contentMode = .scaleAspectFit

        chargeImageView.setDimensionContraints(width: 80.0)

        let textStackView = UIStackView.getVerticalStackView(withSpacing: 5.0,
                                                             views: [
                                                                chargeLabel,
                                                                statusLabel,
                                                                voltageLabel
                                                             ])

        textStackView.distribution = .fillEqually

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                     views: [
                                                                        chargeImageView,
                                                                        UIView(),
                                                                        textStackView
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
