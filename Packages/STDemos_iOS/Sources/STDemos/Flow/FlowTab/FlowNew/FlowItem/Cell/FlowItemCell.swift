//
//  File.swift
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

public class FlowItemCell: BaseTableViewCell {
    let containerView = UIView()

    let flowItemCellImage = UIImageView()
    let flowItemCellLabel = UILabel()
    let flowItemCellSettingsButton = UIButton()
    let flowItemCellDeleteButton = UIButton()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        flowItemCellImage.setDimensionContraints(width: 20.0, height: 20.0)
        flowItemCellLabel.numberOfLines = 0
        flowItemCellDeleteButton.isHidden = true
        
        flowItemCellSettingsButton.setDimensionContraints(width: 30.0)
        flowItemCellDeleteButton.setDimensionContraints(width: 30.0)
        
        let itemStackView = UIStackView.getHorizontalStackView(
            withSpacing: 8.0,
            views: [
                flowItemCellImage,
                flowItemCellLabel,
                UIView(),
                flowItemCellSettingsButton,
                flowItemCellDeleteButton
            ]
        )
        itemStackView.distribution = .fill
        
        containerView.addSubview(itemStackView)
        itemStackView.addFitToSuperviewConstraints(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 8.0
        self.containerView.backgroundColor = .white
        self.containerView.layer.borderColor = ColorLayout.primary.light.cgColor
        containerView.layer.borderWidth = 0.5
        containerView.applyShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
