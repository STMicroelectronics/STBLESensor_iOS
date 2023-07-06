//
//  AccEventSingleView.swift
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

class AccEventSingleView: UIView {
    
    var image = UIImageView()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        image.image = ImageLayout.image(with: "acc_event_none", in: .module)
        image.contentMode = .center
        
        let sv = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            image
        ])
        sv.distribution = .fillEqually
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(sv)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
