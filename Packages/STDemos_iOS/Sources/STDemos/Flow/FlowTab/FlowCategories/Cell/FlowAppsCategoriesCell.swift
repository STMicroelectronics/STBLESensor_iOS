//
//  FlowAppsCategoriesCell.swift
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

public class FlowAppsCategoriesCell: BaseTableViewCell {
    let containerView = UIView()

    let flowAppCategoryIcon = UIImageView()
    let flowAppCategoryName = UILabel()
    let flowAppCategoryDisclosureIcon = UIImageView()
    let flowAppCategoryDeleteIcon = UIImageView()
    
    var flowAppCategoryDeleteSV = UIStackView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        flowAppCategoryIcon.setDimensionContraints(width: 40.0, height: 40.0)
        flowAppCategoryDisclosureIcon.setDimensionContraints(width: 40.0, height: 40.0)

        flowAppCategoryName.numberOfLines = 0
        
        let discosureSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            UIView(),
            flowAppCategoryDisclosureIcon,
            UIView()
        ])
        discosureSV.distribution = .equalCentering
        
        flowAppCategoryDeleteSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            UIView(),
            flowAppCategoryDeleteIcon,
            UIView()
        ])
        flowAppCategoryDeleteSV.distribution = .equalCentering
        flowAppCategoryDeleteSV.isHidden = true
        
        let itemStackView = UIStackView.getHorizontalStackView(
            withSpacing: 16.0,
            views: [
                flowAppCategoryIcon.embedInView(with: .standardEmbed),
                flowAppCategoryName,
                UIView(),
                discosureSV,
                flowAppCategoryDeleteSV
            ]
        )
        itemStackView.distribution = .fill
        
        let stackView = UIStackView.getVerticalStackView(
            withSpacing: 10,
            views: [
                itemStackView
            ]
        )
        stackView.distribution = .fill
        
        containerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)
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
