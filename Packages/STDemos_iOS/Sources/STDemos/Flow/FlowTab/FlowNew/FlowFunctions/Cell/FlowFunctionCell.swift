//
//  FlowFunctionCell.swift
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

public class FlowFunctionCell: BaseTableViewCell {
    let containerView = UIView()

    let functionSelector = UISwitch()
    let functionLabel = UILabel()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)
        
        functionLabel.numberOfLines = 0
        
        functionSelector.onTintColor = ColorLayout.primary.auto
        
        let itemStackView = UIStackView.getHorizontalStackView(
            withSpacing: 16.0,
            views: [
                functionSelector,
                functionLabel,
                UIView()
            ]
        )
        itemStackView.distribution = .fill
        
        containerView.addSubview(itemStackView)
        itemStackView.addFitToSuperviewConstraints(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

