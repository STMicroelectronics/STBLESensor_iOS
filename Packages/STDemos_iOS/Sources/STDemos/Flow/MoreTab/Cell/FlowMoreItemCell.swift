//
//  FlowMoreItemCell.swift
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

public class FlowMoreItemCell: BaseTableViewCell {
    let containerView = UIView()

    let itemIcon = UIImageView()
    let itemLabel = UILabel()
    let itemDisclosureIcon = UIImageView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        itemIcon.setDimensionContraints(width: 40.0, height: 40.0)
        itemDisclosureIcon.setDimensionContraints(width: 40.0, height: 40.0)

        let emptyView = UIView()
        
        let itemStackView = UIStackView.getHorizontalStackView(
            withSpacing: 8.0,
            views: [
                itemIcon.embedInView(with: .standardEmbed),
                itemLabel,
                emptyView,
                itemDisclosureIcon.embedInView(with: .standardEmbed)
            ]
        )

        itemStackView.distribution = .fill
        
        let stackView = UIStackView.getVerticalStackView(
            withSpacing: 10,
            views: [
                itemStackView
            ]
        )

        containerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints()
        stackView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
