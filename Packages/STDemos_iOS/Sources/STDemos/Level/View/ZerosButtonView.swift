//
//  ZerosButtonView.swift
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

class ZerosButtonView: UIView {
    
    let setZeroButton = UIButton()
    let resetZeroButton = UIButton()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        Buttonlayout.standardWithSmallFont.apply(to: setZeroButton, text: "SET ZERO")
        Buttonlayout.standardWithSmallFont.apply(to: resetZeroButton, text: "RESET ZERO")
        
        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            setZeroButton,
            resetZeroButton
        ])
        horizontalStackView.distribution = .fill
        
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
