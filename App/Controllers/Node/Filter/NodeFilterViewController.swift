//
//  NodeFilterViewController.swift
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
import STBlueSDK

final class NodeFilterViewController: BaseNoViewController<NodeFilterDelegate> {

    let containerView = UIView()
    let sliderView = UISlider()
    let currentValueLabel = UILabel()

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "NodeFilter_title"

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        view.backgroundColor = .clear

        containerView.backgroundColor = .white
        view.addSubview(containerView)

        containerView.activate(constraints: [
            equal(\.bottomAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ])

        containerView.setDimensionContraints(height: 200.0)

        let actionButton = UIButton(type: .custom)
        actionButton.setImage(ImageLayout.Common.chevronDown?.maskWithColor(color: .lightGray),
                              for: .normal)

        actionButton.onTap { [weak self] _ in
            self?.presenter.dismisss()
        }

        containerView.addSubview(actionButton)

        actionButton.activate(constraints: [
            equal(\.topAnchor),
            equal(\.trailingAnchor)
        ])

        actionButton.setDimensionContraints(width: 50.0, height: 50.0)

        let minLabel = UILabel()
        minLabel.text = "-4 dBm"

        let maxLabel = UILabel()
        maxLabel.text = "-100 dBm"

        TextLayout.info.apply(to: minLabel)
        TextLayout.info.apply(to: maxLabel)

        sliderView.tintColor = ColorLayout.secondary.light

        let titleLabel = UILabel()
        titleLabel.text = Localizer.NodeFilter.Text.title.localized

        TextLayout.title.apply(to: titleLabel)

        currentValueLabel.text = ""

        TextLayout.info.alignment(.center).apply(to: currentValueLabel)

        let hStackview = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                            views: [
                                                                minLabel,
                                                                sliderView,
                                                                maxLabel
                                                            ])

        let vStackview = UIStackView.getVerticalStackView(withSpacing: 10.0,
                                                            views: [
                                                                titleLabel,
                                                                hStackview,
                                                                currentValueLabel
                                                            ])

        containerView.addSubview(vStackview)

        vStackview.activate(constraints: [
            equal(\.centerYAnchor),
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerView.layer.cornerRadius = 8.0
        containerView.applyShadow()
    }
}
