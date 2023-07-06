//
//  DemoCell.swift
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

public class DemoCell: BaseTableViewCell {

    let containerDemoImage = UIView()
    let demoImageView = UIImageView()
    let demoTextLabel = UILabel()
    let demoDetailTextLabel = UILabel()
    let lockImageView = UIImageView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        containerDemoImage.addSubview(demoImageView, constraints: [
            equal(\.leadingAnchor, constant: 8),
            equal(\.trailingAnchor, constant: -8),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 8),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        let textStackView = UIStackView.getVerticalStackView(withSpacing: 0,
                                                             views: [
                                                                demoTextLabel,
                                                                demoDetailTextLabel
                                                             ])

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 10,
                                                                     views: [
                                                                        containerDemoImage,
                                                                        textStackView,
                                                                        lockImageView
                                                                     ])

        demoTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        contentView.addSubview(horizontalStackView)
        horizontalStackView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        containerDemoImage.setDimensionContraints(width: 85.0, height: 85)
        containerDemoImage.layer.cornerRadius = 8.0
        
        lockImageView.setDimensionContraints(width: 60.0)
        
        horizontalStackView.setDimensionContraints(height: 85.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
