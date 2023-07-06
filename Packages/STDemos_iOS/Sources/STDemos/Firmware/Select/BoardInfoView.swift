//
//  BoardInfoView.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public class BoardInfoView: UIView {

    let containerView = UIView()

    let nameLabel = UILabel()
    let versionLabel = UILabel()
    let mcuTypeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(containerView)

        TextLayout.info.apply(to: nameLabel)
        TextLayout.info.apply(to: versionLabel)
        TextLayout.info.apply(to: mcuTypeLabel)

        containerView.addFitToSuperviewConstraints(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
        containerView.backgroundColor = .white

        let firstLineStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                    views: [
                                                                        label(with: "Name:"),
                                                                        nameLabel
                                                                    ])
        let secondLineStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                     views: [
                                                                        label(with: "Version:"),
                                                                        versionLabel
                                                                     ])
        let thirdLineStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                    views: [
                                                                        label(with: "MCU Type:"),
                                                                        mcuTypeLabel
                                                                    ])

        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 10.0,
                                                                 views: [ firstLineStackView, secondLineStackView, thirdLineStackView ])

        containerView.addSubview(verticalStackView)
        verticalStackView.addFitToSuperviewConstraints(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.cornerRadius = 8.0
        containerView.applyShadow()
    }
}

private extension BoardInfoView {
    func label(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text

        TextLayout.info.apply(to: label)

        return label
    }
}
