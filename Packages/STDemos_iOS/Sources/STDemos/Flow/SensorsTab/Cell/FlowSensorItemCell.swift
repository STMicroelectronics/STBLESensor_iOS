//
//  FlowSensorItemCell.swift
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

public class FlowSensorItemCell: BaseTableViewCell {
    let containerView = UIView()

    let flowSensorIcon = UIImageView()
    let flowSensorName = UILabel()
    let flowSensorDetailedName = UILabel()
    let flowSensorDisclosureIcon = UIImageView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        flowSensorIcon.setDimensionContraints(width: 40.0, height: 40.0)
        flowSensorDisclosureIcon.setDimensionContraints(width: 40.0, height: 40.0)

        flowSensorName.numberOfLines = 0
        flowSensorDetailedName.numberOfLines = 0
        
        let flowSensorNamesStackView = UIStackView.getVerticalStackView(
            withSpacing: 4.0,
            views: [
                UIView(),
                flowSensorName,
                flowSensorDetailedName,
                UIView()
            ]
        )
        
        flowSensorNamesStackView.distribution = .equalCentering
        
        let itemStackView = UIStackView.getHorizontalStackView(
            withSpacing: 4.0,
            views: [
                flowSensorIcon.embedInView(with: .standardEmbed),
                flowSensorNamesStackView,
                UIView(),
                flowSensorDisclosureIcon.embedInView(with: .standardEmbed)
            ]
        )

        itemStackView.distribution = .fill
 
        containerView.addSubview(itemStackView)
        itemStackView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)
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
