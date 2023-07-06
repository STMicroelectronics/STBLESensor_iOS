//
//  RegisterAiCell.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public class RegisterAiCell: BaseTableViewCell {

    var containerView = UIView()
    var mainStackView = UIStackView()
    
    let registerImageView = UIImageView()
    let registerTitleTextLabel = UILabel()
    let registerAlgorithmTextLabel = UILabel()
    let registerValueTextLabel = UILabel()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let labelsStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            registerAlgorithmTextLabel,
            registerValueTextLabel
        ])

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            labelsStackView,
            registerImageView
        ])
        
        mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            registerTitleTextLabel,
            horizontalStackView
        ])
        mainStackView.distribution = .fill
        
        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)
        
        containerView.addSubview(mainStackView)
        mainStackView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        registerImageView.setDimensionContraints(width: 48.0, height: 48.0)
        
        registerTitleTextLabel.numberOfLines = 0
        registerAlgorithmTextLabel.numberOfLines = 0
        registerValueTextLabel.numberOfLines = 0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
            self.containerView.layer.cornerRadius = 8.0
            self.containerView.backgroundColor = .white
            containerView.applyShadow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
