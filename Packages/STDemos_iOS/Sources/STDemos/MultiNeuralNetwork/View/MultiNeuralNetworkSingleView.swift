//
//  MultiNeuralNetworkSingleView.swift
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

class MultiNeuralNetworkSingleView: UIView {
    
    let title = UILabel()
    let state = UILabel()
    let image = UIImageView()
    let descritpion = UILabel()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image.setDimensionContraints(width: 125, height: 125)
        image.image = ImageLayout.image(with: "fitness_unknown", in: .module)
        image.contentMode = .scaleAspectFit
        
        TextLayout.bold.apply(to: title)
        TextLayout.info.apply(to: state)
        
        title.numberOfLines = 1
        descritpion.textAlignment = .center

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 0, views: [
            title,
            UIView(),
            state
        ])
        
        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            horizontalStackView,
            image,
            descritpion
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
