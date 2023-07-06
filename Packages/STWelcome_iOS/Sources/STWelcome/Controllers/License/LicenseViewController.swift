//
//  LicenseViewController.swift
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

public final class LicenseViewController: BaseNoViewController<LicenseDelegate> {

    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    let licenseLabel = UILabel()
    let actionButtton = UIButton()

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        presenter.load()
    }

    public override func configureView() {
        super.configureView()

        titleLabel.numberOfLines = 0
        TextLayout.largetitle.apply(to: titleLabel)
        titleLabel.text = "License Agreement"
        
        subTitleLabel.numberOfLines = 0
        subTitleLabel.text = "Please read carefully the license agreement. If you accept the terms below click 'I agree'otherwise quit the application."
        subTitleLabel.font = FontLayout.font(size: 13, weight: .bold)
        
        licenseLabel.numberOfLines = 0
        
        Buttonlayout.standard.apply(
            to: actionButtton,
            text: Localizer.Welcome.Action.accept.localized
        )

        let stackView = UIStackView.getVerticalStackView(withSpacing: 16.0, views: [
            titleLabel,
            subTitleLabel,
            licenseLabel,
            actionButtton.embedInView(with: .standard)
        ])

        actionButtton.onTap { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
    }
}
