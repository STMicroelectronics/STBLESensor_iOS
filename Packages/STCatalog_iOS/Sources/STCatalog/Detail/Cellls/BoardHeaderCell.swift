//
//  BoardHeaderView.swift
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

public class BoardHeaderCell: BaseTableViewCell {

    let containerView = UIView()

    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let statusLabel = UILabel()
    let nodeImageView = UIImageView()
    let descriptionLabel = UILabel()

    let firmwareButton = UIButton(type: .custom)
    let datasheetButton = UIButton(type: .custom)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        nodeImageView.setDimensionContraints(height: 120.0)

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        let titleTextStackView = UIStackView.getVerticalStackView(withSpacing: 8.0,
                                                                views: [
                                                                    titleLabel,
                                                                    subtitleLabel,
                                                                    statusLabel
                                                                ])


        titleTextStackView.setDimensionContraints(height: 80.0)
        iconImageView.setDimensionContraints(width: 60.0)


        let titleStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                views: [
                                                                    //iconImageView.embedInView(with: .standardEmbed),
                                                                    //titleTextStackView.embedInView(with: .standardTopBottom)
                                                                    titleTextStackView.embedInView(with: .standardEmbed)
                                                                ])

        let imageContainerView = nodeImageView.embedInView(with: .standardEmbed)
        imageContainerView.backgroundColor = ColorLayout.systemWhite.light

        let divisor = UIView()
        divisor.backgroundColor = ColorLayout.stGray5.light
        divisor.setDimensionContraints(height: 1)

        Buttonlayout.textSecondaryColor.apply(to: firmwareButton, text: Localizer.CatalogDetail.Action.firmware.localized)
        Buttonlayout.textSecondaryColor.apply(to: datasheetButton, text: Localizer.CatalogDetail.Action.datasheets.localized)

        let actionStackView = UIStackView.getHorizontalStackView(withSpacing: 20.0,
                                                                 views: [
                                                                    firmwareButton,
                                                                    datasheetButton,
                                                                    UIView()
                                                                 ])

        let stackView = UIStackView.getVerticalStackView(withSpacing: 10,
                                                         views: [
                                                            titleStackView,
                                                            imageContainerView,
                                                            descriptionLabel.embedInView(with: .standardEmbed),
                                                            divisor,
                                                            actionStackView
                                                         ])

        containerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints()
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
