//
//  WorkInProgressViewController.swift
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

final class WorkInProgressViewController: BaseNoViewController<WorkInProgressDelegate> {

    var containerLegacyView = UIView()
    let legacyView = LegacyView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "WorkInProgress_title"

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        containerLegacyView = legacyView.embedInView(with: .standard)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            UIView(),
            containerLegacyView,
            UIView()
        ])
        mainStackView.distribution = .equalSpacing
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let badgeTap = UITapGestureRecognizer(target: self, action: #selector(badgeTapped(_:)))
        legacyView.badge.addGestureRecognizer(badgeTap)
        legacyView.badge.isUserInteractionEnabled = true
        
        legacyView.title.text = "Work In Progress"
        legacyView.legacyDescription.text = "This Demo is work in progress. Please download and use the ST BLE Sensor Classic version.\nClick on the badge below."
    }

}

extension WorkInProgressViewController {
    @objc
    func badgeTapped(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://apps.apple.com/it/app/st-ble-sensor-classic/id6447749695") {
            UIApplication.shared.open(url)
        }
    }
}
