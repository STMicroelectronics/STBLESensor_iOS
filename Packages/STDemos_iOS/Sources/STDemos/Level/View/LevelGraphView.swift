//
//  LevelGraphView.swift
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

class LevelGraphView: UIView {

    let mainView = UIView()
    
    let mainCircle = UIImageView()
    
    let circle = UIImageView()
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainCircle.image = ImageLayout.image(with: "level_circle", in: .module)?.withTintColor(ColorLayout.primary.light)
        mainCircle.alpha = 0.5
        mainCircle.contentMode = .scaleAspectFit
        
        let centerCircle = UIImageView()
        centerCircle.image = ImageLayout.image(with: "level_circle", in: .module)?.withTintColor(ColorLayout.primary.light)
        centerCircle.alpha = 0.5
        
        circle.image = ImageLayout.image(with: "level_circle", in: .module)?.withTintColor(UIColor.systemGreen)

        mainView.setDimensionContraints(width: 300, height: 300)
        
        mainCircle.setDimensionContraints(width: 300, height: 300)
        centerCircle.setDimensionContraints(width: 30, height: 30)
        circle.setDimensionContraints(width: 30, height: 30)
        
        mainView.addSubview(mainCircle, constraints:[
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ])
        
        mainView.addSubview(centerCircle, constraints:[
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ])
        
        mainView.addSubview(circle, constraints:[
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ])
        
        let horizontalSv = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            mainView,
            UIView()
        ])
        horizontalSv.distribution = .equalCentering
        
        let sv = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            horizontalSv
        ])
        sv.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 8),
            equal(\.bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(sv)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
