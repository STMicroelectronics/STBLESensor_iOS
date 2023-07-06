//
//  AppInfoViewController.swift
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
import STCore

final class AppInfoViewController: BaseNoViewController<AppInfoDelegate> {

    var betaTapCounter = 0

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Application Info"

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        let appNameLabel = UILabel()
        let appLogo = UIImageView()
        let appVersionLabel = UILabel()
        let appBuildLabel = UILabel()

        appNameLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        TextLayout.largetitle.apply(to: appNameLabel)
        appNameLabel.textAlignment = .center

        appLogo.image = ImageLayout.image(with: "logo", in: .main)
        appLogo.contentMode = .scaleAspectFit
        appLogo.setDimensionContraints(width: 300, height: 300)

        appVersionLabel.text = "v\(STCore.appShortVersion)"
        TextLayout.title.apply(to: appVersionLabel)
        appVersionLabel.textAlignment = .center

        appBuildLabel.text = "Build \(STCore.appVersion)"
        TextLayout.text.apply(to: appBuildLabel)
        appBuildLabel.textAlignment = .center

        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            appLogo,
            appNameLabel,
            appVersionLabel,
            appBuildLabel,
            UIView()
        ])
        mainStackView.distribution = .fill

        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        let buildLabelTap = UITapGestureRecognizer(target: self, action: #selector(buildLabelTapped(_:)))
        appBuildLabel.isUserInteractionEnabled = true
        appBuildLabel.addGestureRecognizer(buildLabelTap)
    }
}

extension AppInfoViewController {
    @objc
    func buildLabelTapped(_ sender: UITapGestureRecognizer) {
        betaTapCounter += 1
        if betaTapCounter == 5 {
            presenter.loadBetaAlert()
        }
    }
}
