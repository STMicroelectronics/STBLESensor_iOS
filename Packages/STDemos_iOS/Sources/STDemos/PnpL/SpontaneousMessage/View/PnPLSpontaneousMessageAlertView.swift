//
//  PnPLSpontaneousMessageAlertView.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public class PnPLSpontaneousMessageAlertView: UIView {
    var titleIcon = UIImageView()
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var extraLabel = UILabel()
    var actionButton = UIButton()

    var dialogOkButton = UIButton()
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleIcon.setDimensionContraints(width: 24, height: 24)
        
        let titleStackView = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            titleIcon,
            titleLabel
        ])
        
        let completeSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            titleStackView,
            descriptionLabel,
            extraLabel,
            UIStackView.getHorizontalStackView(withSpacing: 0.0,
                                               views: [
                                                UIView(),
                                                actionButton
                                               ]),
            dialogOkButton
        ])
        completeSV.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(completeSV)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        applyShadow(with: .systemGray)
    }
}
