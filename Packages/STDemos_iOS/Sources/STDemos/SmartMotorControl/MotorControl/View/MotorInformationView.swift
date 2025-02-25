//
//  MotorInformationView.swift
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

class MotorInformationView: UIView {
    
    let motorStatusImage = UIImageView()
    let motorStatusMessage = UILabel()
    
    let motorButton = UIButton()
    let motorStatusLabel = UILabel()
    
    var motorSpeedStackView = UIStackView()
    let motorSpeedSlider = UISlider()
    let motorSpeedLabel = UILabel()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let motorImage = UIImageView()
        motorImage.image = ImageLayout.image(with: "demo_smart_motor_control", in: STUI.bundle)
        motorImage.contentMode = .scaleAspectFit
        motorImage.setDimensionContraints(width: 80, height: 80)
        
        let motorTitleLabel = UILabel()
        motorTitleLabel.text = "Motor Information"
        TextLayout.title2.apply(to: motorTitleLabel)
        
        motorStatusImage.contentMode = .scaleAspectFit
        motorStatusImage.setDimensionContraints(width: 20, height: 20)
        
        TextLayout.infoBold.apply(to: motorStatusLabel)
        motorStatusLabel.numberOfLines = 0

        let divisor = UIView()
        divisor.backgroundColor = ColorLayout.stGray5.light
        divisor.setDimensionContraints(height: 1)
        
        TextLayout.info.apply(to: motorStatusMessage)
        motorStatusMessage.text = "No fault message"
        motorStatusMessage.numberOfLines = 0
        
        TextLayout.infoBold.apply(to: motorSpeedLabel)
        motorSpeedLabel.numberOfLines = 0
        
        motorSpeedSlider.minimumValue = Float(-4000)
        motorSpeedSlider.maximumValue = Float(4000)
        motorSpeedSlider.minimumTrackTintColor = ColorLayout.secondary.light
   
        let speedMinLabel = UILabel()
        speedMinLabel.text = "-4000"
        
        let speedMaxLabel = UILabel()
        speedMaxLabel.text = "4000"
        
        let motorStatusLabelSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            motorStatusImage,
            motorStatusLabel,
            UIView()
        ])
        motorStatusLabelSV.setDimensionContraints(height: 36)
        
        let motorStatusSV = UIStackView.getVerticalStackView(withSpacing: 0, views: [
            UIView(),
            motorButton,
            motorStatusLabelSV,
            UIView()
        ])
        motorStatusSV.distribution = .fill
        
        let mImageSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            motorImage,
            UIView(),
            motorStatusSV
        ])

        let motorSpeedProgressSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            speedMinLabel,
            motorSpeedSlider,
            speedMaxLabel
        ])
        
        motorSpeedStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            motorStatusMessage,
            divisor,
            motorSpeedLabel,
            motorSpeedProgressSV
        ])
        motorSpeedStackView.distribution = .fill
        
        motorSpeedStackView.isHidden = true
        
        let motorInfoSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            mImageSV,
            motorTitleLabel,
//            motorStatusSV,
            motorSpeedStackView
        ])
        motorInfoSV.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 0.0),
            equal(\.trailingAnchor, constant: -0.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(motorInfoSV)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
