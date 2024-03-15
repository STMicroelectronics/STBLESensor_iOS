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
    let motorStatusLabel = UILabel()
    let motorStatusMessage = UILabel()
    
    let motorButton = UIButton()
    
    let motorSpeedProgressBar = UIProgressView()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let motorImage = UIImageView()
        motorImage.image = ImageLayout.image(with: "demo_smart_motor_control", in: STUI.bundle)
        motorImage.contentMode = .scaleAspectFit
        motorImage.setDimensionContraints(width: 40, height: 40)
        
        let motorTitleLabel = UILabel()
        motorTitleLabel.text = "Motor Information"
        TextLayout.title2.apply(to: motorTitleLabel)
        
        motorStatusImage.image = ImageLayout.image(with: "motor_info_running", in: .module)
        motorStatusImage.contentMode = .scaleAspectFit
        motorStatusImage.setDimensionContraints(width: 24, height: 24)
        
        TextLayout.infoBold.apply(to: motorStatusLabel)
        motorStatusLabel.text = "RUNNING"
        motorStatusLabel.numberOfLines = 0
        motorStatusLabel.textColor = ColorLayout.green.auto
        
        motorButton.setTitle("STOP", for: .normal)
        Buttonlayout.standardGreen.apply(to: motorButton)
        
        let divisor = UIView()
        divisor.backgroundColor = ColorLayout.stGray5.light
        divisor.setDimensionContraints(height: 1)
        
        TextLayout.info.apply(to: motorStatusMessage)
        motorStatusMessage.text = "No fault message"
        motorStatusMessage.numberOfLines = 0
        
        let motorSpeedLabel = UILabel()
        TextLayout.infoBold.apply(to: motorSpeedLabel)
        motorSpeedLabel.text = "Motor Speed"
        motorSpeedLabel.numberOfLines = 0
        
        motorSpeedProgressBar.setProgress(0, animated: true)
        motorSpeedProgressBar.progressTintColor = ColorLayout.primary.light
        
        let speedMinLabel = UILabel()
        speedMinLabel.text = "0"
        
        let speedMaxLabel = UILabel()
        speedMaxLabel.text = "100"
        
        let mImageSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            motorImage,
            UIView()
        ])
        
        let motorStatusSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            motorStatusImage,
            motorStatusLabel,
            UIView(),
            motorButton
        ])
        
        let motorSpeedProgressSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            speedMinLabel,
            motorSpeedProgressBar,
            speedMaxLabel
        ])
        
        let motorInfoSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            mImageSV,
            motorTitleLabel,
            motorStatusSV,
            motorStatusMessage,
            divisor,
            motorSpeedLabel,
            motorSpeedProgressSV
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
