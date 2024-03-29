//
//  FirmwareCell.swift
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

public class FirmwareCell: BaseTableViewCell {

    let containerView = UIView()

    let titleLabel = UILabel()
    let versionLabel = UILabel()
    let maturityLabel = UILabel()
    let changelogLabel = UILabel()
    let availableDemosLabel = UILabel()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        maturityLabel.isHidden = true
        TextLayout.accentBold.apply(to: maturityLabel)
        
        let divisor = UIView()
        divisor.backgroundColor = ColorLayout.stGray5.light
        divisor.setDimensionContraints(height: 1)
        
        let availableDemosTitleLabel = UILabel()
        availableDemosTitleLabel.text = "Available Demos"
        TextLayout.infoBold.apply(to: availableDemosTitleLabel)
        
        let stackView = UIStackView.getVerticalStackView(withSpacing: 10,
                                                         views: [
                                                            titleLabel,
                                                            versionLabel,
                                                            maturityLabel,
                                                            changelogLabel,
                                                            divisor,
                                                            availableDemosTitleLabel,
                                                            availableDemosLabel
                                                         ])

        containerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)
        stackView.layer.cornerRadius = 8.0
        stackView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8.0
        containerView.applyShadow()
    }
}
