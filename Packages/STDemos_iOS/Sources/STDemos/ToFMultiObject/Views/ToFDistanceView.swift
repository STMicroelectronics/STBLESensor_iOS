//
//  ToFDistanceView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STUI

class ToFDistanceView: UIView {
    
    let title = UILabel()
    let valueLabel = UILabel()
    let value = UILabel()
    let unit = UILabel()
    let progress = UIProgressView()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        TextLayout.title2.apply(to: title)
        
        valueLabel.text = "Distance: "
        TextLayout.info.apply(to: valueLabel)
        
        TextLayout.info.apply(to: value)
        TextLayout.info.apply(to: unit)
        
        progress.setProgress(0, animated: true)
        progress.progressTintColor = ColorLayout.primary.light

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            valueLabel,
            UIView(),
            value,
            unit
        ])
        horizontalStackView.distribution = .fill

        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            title,
            horizontalStackView,
            progress
        ])
        verticalStackView.distribution = .fillEqually
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(verticalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
