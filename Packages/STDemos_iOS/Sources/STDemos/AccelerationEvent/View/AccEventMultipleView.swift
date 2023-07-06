//
//  AccEventMultipleView.swift
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

class AccEventMultipleView: UIView {
    
    let orientationImage = UIImageView()
    let orientationLabel = UILabel()

    let pedometerImage = UIImageView()
    let pedometerLabel = UILabel()
    
    let tapImage = UIImageView()
    let tapLabel = UILabel()
    
    let freeFallImage = UIImageView()
    let freeFallLabel = UILabel()
    
    let doubleTapImage = UIImageView()
    let doubleTapLabel = UILabel()
    
    let tiltImage = UIImageView()
    let tiltLabel = UILabel()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupOrientation()
        let orientationSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            orientationImage,
            orientationLabel
        ])
        orientationSV.distribution = .fillEqually

        setupPedometer()
        let pedometerSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            pedometerImage,
            pedometerLabel
        ])
        pedometerSV.distribution = .fillEqually
        
        setupTap()
        let tapSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            tapImage,
            tapLabel
        ])
        tapSV.distribution = .fillEqually
        
        setupFreeFall()
        let freeFallSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            freeFallImage,
            freeFallLabel
        ])
        freeFallSV.distribution = .fillEqually
        
        setupWakeUp()
        let wakeUpSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            doubleTapImage,
            doubleTapLabel
        ])
        wakeUpSV.distribution = .fillEqually
        
        setupTilt()
        let tiltSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            tiltImage,
            tiltLabel
        ])
        tiltSV.distribution = .fillEqually
        
        let row1SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            orientationSV,
            pedometerSV
        ])
        row1SV.distribution = .fillEqually
        
        let row2SV = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            tapSV,
            freeFallSV
        ])
        row2SV.distribution = .fillEqually
        
        let row3SV = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            wakeUpSV,
            tiltSV
        ])
        row3SV.distribution = .fillEqually
        
        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            row1SV,
            row2SV,
            row3SV
        ])
        verticalStackView.distribution = .fillEqually
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 8.0),
            equal(\.trailingAnchor, constant: -8.0),
            equal(\.topAnchor, constant: 8),
            equal(\.bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(verticalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupOrientation() {
        orientationImage.image = ImageLayout.image(with: "acc_event_orientation_up", in: .module)
        orientationImage.contentMode = .scaleAspectFit
        TextLayout.info.apply(to: orientationLabel)
        orientationLabel.text = "Orientation"
        orientationLabel.textAlignment = .center
    }
    
    private func setupPedometer(){
        pedometerImage.image = ImageLayout.image(with: "pedometer", in: .module)
        pedometerImage.contentMode = .scaleAspectFit
        TextLayout.info.apply(to: pedometerLabel)
        pedometerLabel.text = "Steps: 0"
        pedometerLabel.textAlignment = .center
    }
    
    private func setupTap() {
        tapImage.image = ImageLayout.image(with: "acc_event_single_tap", in: .module)
        tapImage.contentMode = .scaleAspectFit
        TextLayout.info.apply(to: tapLabel)
        tapLabel.text = "Tap"
        tapLabel.textAlignment = .center
    }
    
    private func setupFreeFall() {
        freeFallImage.image = ImageLayout.image(with: "acc_event_free_fall", in: .module)
        freeFallImage.contentMode = .scaleAspectFit
        TextLayout.info.apply(to: freeFallLabel)
        freeFallLabel.text = "Free Fall"
        freeFallLabel.textAlignment = .center
    }
    
    private func setupWakeUp() {
        doubleTapImage.image = ImageLayout.image(with: "acc_event_double_tap", in: .module)
        doubleTapImage.contentMode = .scaleAspectFit
        TextLayout.info.apply(to: doubleTapLabel)
        doubleTapLabel.text = "Double Tap"
        doubleTapLabel.textAlignment = .center
    }
    
    private func setupTilt() {
        tiltImage.image = ImageLayout.image(with: "acc_event_tilt", in: .module)
        tiltImage.contentMode = .scaleAspectFit
        TextLayout.info.apply(to: tiltLabel)
        tiltLabel.text = "Tilt"
        tiltLabel.textAlignment = .center
    }
}
