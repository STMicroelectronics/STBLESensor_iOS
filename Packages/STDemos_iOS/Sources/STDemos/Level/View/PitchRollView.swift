//
//  PitchRollView.swift
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

class PitchRollView: UIView {
    
    let pitchImageView = UIImageView()
    let pitchOffsetLabel = UILabel()

    let rollImageView = UIImageView()
    let rollOffsetLabel = UILabel()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pitchDescriptionLabel = UILabel()
        pitchDescriptionLabel.text = "Pitch"
        TextLayout.info.apply(to: pitchDescriptionLabel)
        pitchDescriptionLabel.textAlignment = .center
        pitchOffsetLabel.text = "Offset: -67.41°"
        TextLayout.info.apply(to: pitchOffsetLabel)
        pitchOffsetLabel.textAlignment = .center
        
        let rollDescriptionLabel = UILabel()
        rollDescriptionLabel.text = "Roll"
        TextLayout.info.apply(to: rollDescriptionLabel)
        rollDescriptionLabel.textAlignment = .center
        rollOffsetLabel.text = "Offset: 3.41°"
        TextLayout.info.apply(to: rollOffsetLabel)
        rollOffsetLabel.textAlignment = .center
        
        pitchImageView.image = ImageLayout.image(with: "level_half_circle", in: .module)?.withTintColor(ColorLayout.primary.light)
        rollImageView.image = ImageLayout.image(with: "level_half_circle", in: .module)?.withTintColor(ColorLayout.primary.light)

        let pitchSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            pitchDescriptionLabel,
            pitchImageView,
            pitchOffsetLabel
        ])
        pitchSV.distribution = .equalCentering
        
        let rollSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            rollDescriptionLabel,
            rollImageView,
            rollOffsetLabel
        ])
        rollSV.distribution = .equalCentering
        
        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            pitchSV,
            rollSV
        ])
        horizontalStackView.distribution = .equalCentering
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 8),
            equal(\.bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(horizontalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
