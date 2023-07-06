//
//  MultiNeuralNetworkCurrentAlgorithm.swift
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

class MultiNeuralNetworkCurrentAlgorithmView: UIView {
    
    let currentAlgorithm = UILabel()
    let button = UIButton()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let infoLabel = UILabel()
        infoLabel.text = "Current Algorithm: "
        
        TextLayout.bold.apply(to: infoLabel)
        TextLayout.info.apply(to: currentAlgorithm)
        
        infoLabel.numberOfLines = 1
        
        button.setTitle("Change Algorithm", for: .normal)
        Buttonlayout.standard.apply(to: button)

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 0, views: [
            infoLabel,
            UIView(),
            currentAlgorithm
        ])
        
        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            horizontalStackView,
            button
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
