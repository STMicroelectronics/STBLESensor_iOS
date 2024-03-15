//
//  BoardCell.swift
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

public class BoardCell: BaseTableViewCell {

    let containerView = UIView()

    let nodeImageView = UIImageView()
    let nodeTextLabel = UILabel()
    var nodeVariantView = UIView()
    let nodeVariantLabel = UILabel()
    let nodeDetailTextLabel = UILabel()
    let nodeReleaseDateLabel = UILabel()
    let nodeExtraTextLabel = UILabel()
    let nodeStatusLabel = UILabel()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        nodeImageView.setDimensionContraints(width: 80.0, height: 220.0)
        
        nodeVariantView = nodeVariantLabel.embedInView(with: .standard)

        let stackView = UIStackView.getVerticalStackView(withSpacing: 8,
                                                         views: [
                                                            nodeTextLabel.embedInView(with: .standard.top(10.0)),
                                                            nodeVariantView,
                                                            nodeDetailTextLabel.embedInView(with: .standard),
                                                            nodeReleaseDateLabel.embedInView(with: .standard),
                                                            nodeExtraTextLabel.embedInView(with: .standard),
                                                            UIView(),
                                                            nodeStatusLabel.embedInView(with: .standard)
                                                         ])

        let imageContainerView = nodeImageView.embedInView(with: .standardEmbed)
        imageContainerView.backgroundColor = ColorLayout.stGray5.light.withAlphaComponent(0.5)
        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 0.0, views: [
            imageContainerView,
            stackView.embedInView(with: .standardEmbed)
        ])

        containerView.addSubview(horizontalStackView)
        horizontalStackView.addFitToSuperviewConstraints()
        horizontalStackView.layer.cornerRadius = 8.0
        horizontalStackView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8.0
        containerView.applyShadow()
    }
}
