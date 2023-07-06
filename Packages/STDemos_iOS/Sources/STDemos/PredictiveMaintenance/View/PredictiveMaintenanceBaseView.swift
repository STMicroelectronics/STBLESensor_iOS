//
//  PredictiveMaintenanceBaseView.swift
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

class PredictiveMaintenanceBaseView: UIView {
    
    let title = UILabel()
    
    let xImage = UIImageView()
    let xLabel = UILabel()
    let xMeasure = UILabel()
    let xFrequency = UILabel()
    
    let yImage = UIImageView()
    let yLabel = UILabel()
    let yMeasure = UILabel()
    let yFrequency = UILabel()
    
    let zImage = UIImageView()
    let zLabel = UILabel()
    let zMeasure = UILabel()
    let zFrequency = UILabel()

    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        TextLayout.title2.apply(to: title)
        
        xImage.image = ImageLayout.image(with: "predictive_warning", in: .module)
        xImage.setDimensionContraints(width: 50)
        xImage.contentMode = .center
        let xInfoLabel = UILabel()
        xInfoLabel.text = "X:"
        xLabel.text = "Unknown"
        TextLayout.bold.apply(to: xInfoLabel)
        TextLayout.bold.apply(to: xLabel)
        
        yImage.image = ImageLayout.image(with: "predictive_warning", in: .module)
        yImage.setDimensionContraints(width: 50)
        yImage.contentMode = .center
        let yInfoLabel = UILabel()
        yInfoLabel.text = "Y:"
        yLabel.text = "Unknown"
        TextLayout.bold.apply(to: yInfoLabel)
        TextLayout.bold.apply(to: yLabel)
        
        zImage.image = ImageLayout.image(with: "predictive_warning", in: .module)
        zImage.setDimensionContraints(width: 50)
        zImage.contentMode = .center
        let zInfoLabel = UILabel()
        zInfoLabel.text = "Z:"
        zLabel.text = "Unknown"
        TextLayout.bold.apply(to: zInfoLabel)
        TextLayout.bold.apply(to: zLabel)

        let xLabelSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            UIStackView.getHorizontalStackView(withSpacing: 8, views: [ xInfoLabel, xLabel, UIView() ]),
            xMeasure,
            xFrequency
        ])
        xLabelSV.distribution = .equalCentering
        
        let yLabelSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            UIStackView.getHorizontalStackView(withSpacing: 8, views: [ yInfoLabel, yLabel, UIView() ]),
            yMeasure,
            yFrequency
        ])
        yLabelSV.distribution = .fill
        
        let zLabelSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            UIStackView.getHorizontalStackView(withSpacing: 8, views: [ zInfoLabel, zLabel, UIView() ]),
            zMeasure,
            zFrequency
        ])
        zLabelSV.distribution = .fill
        
        
        let xSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            xImage,
            xLabelSV
        ])
        xSV.distribution = .fill
        
        let ySV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            yImage,
            yLabelSV
        ])
        ySV.distribution = .fill
        
        let zSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            zImage,
            zLabelSV
        ])
        zSV.distribution = .fill
        

        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 32, views: [
            title,
            xSV,
            ySV,
            zSV
        ])
        mainStackView.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(mainStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
