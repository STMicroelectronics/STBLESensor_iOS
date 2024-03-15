//
//  FlowMoreBoardDetailCell.swift
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

public class FlowMoreBoardDetailCell: BaseTableViewCell {
    let containerView = UIView()

    let nodeImage = UIImageView()
    let nodeLabel = UILabel()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        nodeImage.setDimensionContraints(width: 80.0, height: 80.0)
        TextLayout.title2.apply(to: nodeLabel)

        let emptyView = UIView()

        let boardStackView = UIStackView.getHorizontalStackView(
            withSpacing: 8.0,
            views: [
                nodeImage.embedInView(with: .standardEmbed),
                nodeLabel,
                emptyView
            ]
        )
        
        containerView.addSubview(boardStackView)
        boardStackView.addFitToSuperviewConstraints()
        boardStackView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
