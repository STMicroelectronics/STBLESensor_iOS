//
//  FlowOverviewButtonCell.swift
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

public class FlowOverviewButtonCell: BaseTableViewCell {
    let containerView = UIView()

    let editButton = UIButton()
    let playButton = UIButton()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 0.0, leading: 8.0, bottom: 4.0, trailing: 8.0)
        
        let itemStackView = UIStackView.getHorizontalStackView(
            withSpacing: 16.0,
            views: [
                editButton,
                playButton,
            ]
        )
        itemStackView.distribution = .fillEqually
        
        containerView.addSubview(itemStackView)
        itemStackView.addFitToSuperviewConstraints(top: 0.0, leading: 8.0, bottom: 4.0, trailing: 8.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

