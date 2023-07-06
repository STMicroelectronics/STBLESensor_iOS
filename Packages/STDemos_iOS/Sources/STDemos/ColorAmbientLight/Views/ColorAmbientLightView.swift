//
//  ColorAmbientLightView.swift
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

class ColorAmbientLightView: UIView {
    
    let title = UILabel()
    let progress = UIProgressView()
    let stackView = UIStackView()
    let valueLabel = UILabel()
    let value = UILabel()
    let unit = UILabel()
    let min = UILabel()
    let max = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        TextLayout.title2.apply(to: title)
        
        progress.setProgress(0, animated: true)
        progress.progressTintColor = ColorLayout.primary.light
        
        valueLabel.text = "Value: "
        TextLayout.info.apply(to: valueLabel)
        
        TextLayout.info.apply(to: value)
        TextLayout.info.apply(to: unit)
        
        TextLayout.info.apply(to: min)
        TextLayout.info.apply(to: max)

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            valueLabel,
            value,
            unit,
            UIView()
        ])
        horizontalStackView.distribution = .fill

        let minMaxHorizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            min,
            UIView(),
            max
        ])
        minMaxHorizontalStackView.distribution = .fill
        
        let minMaxAndProgressStackView = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            progress,
            minMaxHorizontalStackView
        ])
        minMaxHorizontalStackView.distribution = .fill
        
        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            title,
            horizontalStackView,
            minMaxAndProgressStackView
        ])
        verticalStackView.distribution = .fill
        
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
