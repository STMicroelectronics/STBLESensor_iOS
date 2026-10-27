//
//  ForceUpdateViewController.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class ForceAppUpdateViewController: UIViewController {

    private let appStoreURL: String
    private let logoName: String

    public init(appStoreURL: String, logoName: String) {
        self.appStoreURL = appStoreURL
        self.logoName = logoName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let appIconImageView = UIImageView()
        appIconImageView.image = ImageLayout.image(with: logoName, in: .main)
        appIconImageView.setDimensionContraints(height: 160.0)
        appIconImageView.contentMode = .scaleAspectFit
        
        let firstlabel = UILabel()
        let secondLabel = UILabel()
        
        firstlabel.text = "A new version of the app is required to continue."
        secondLabel.text = "Please update to the latest version to access all features and ensure the best experience."
        
        TextLayout.infoBold.apply(to: firstlabel)
        TextLayout.info.apply(to: secondLabel)
        
        firstlabel.numberOfLines = 0
        secondLabel.numberOfLines = 0
        firstlabel.textAlignment = .center
        secondLabel.textAlignment = .center

        let appstoreButton = UIButton(type: .custom)
        appstoreButton.setImage(ImageLayout.image(with: "appstorebadge", in: .module), for: .normal)
        appstoreButton.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)

        let stack = UIStackView.getVerticalStackView(withSpacing: 20, views: [appIconImageView, firstlabel, secondLabel, appstoreButton])
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc func updateTapped() {
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
}
