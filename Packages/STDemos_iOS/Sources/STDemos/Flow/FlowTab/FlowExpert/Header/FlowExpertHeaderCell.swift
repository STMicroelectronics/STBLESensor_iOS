//
//  FlowExpertHeaderCell.swift
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

public class FlowExpertHeaderCell: BaseTableViewCell {

    let containerView = UIView()

    let newAppButton = UIButton()
    let ifButton = UIButton()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let customAppTitleLabel = UILabel()
        let customAppDescriptionLabel = UILabel()
        let yourAppTitleLabel = UILabel()

        TextLayout.title.apply(to: customAppTitleLabel)
        TextLayout.info.apply(to: customAppDescriptionLabel)
        TextLayout.text.apply(to: yourAppTitleLabel)

        customAppTitleLabel.numberOfLines = 0
        customAppDescriptionLabel.numberOfLines = 0
        yourAppTitleLabel.numberOfLines = 0

        customAppTitleLabel.text = "Custom Apps"
        customAppDescriptionLabel.text = "Upload and run the app on your board."
        yourAppTitleLabel.text = "YOUR APPS"
        
        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        customAppTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        let titleDescriptionTextStackView = UIStackView.getVerticalStackView(
            withSpacing: 8.0, views: [
                customAppTitleLabel,
                customAppDescriptionLabel
            ]
        )
        titleDescriptionTextStackView.distribution = .fill
        
        let yourAppHorizontalStackView = UIStackView.getHorizontalStackView(
            withSpacing: 8.0, views: [
                yourAppTitleLabel,
                UIView(),
                newAppButton,
                ifButton,
            ]
        )
        yourAppHorizontalStackView.distribution = .fill

        let stackView = UIStackView.getVerticalStackView(
            withSpacing: 8, views: [
                titleDescriptionTextStackView,
                yourAppHorizontalStackView
            ]
        )
        stackView.distribution = .fill
        
        containerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
