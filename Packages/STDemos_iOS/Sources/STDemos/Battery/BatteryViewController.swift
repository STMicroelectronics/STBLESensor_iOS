//
//  BatteryViewController.swift
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

final class BatteryViewController: DemoNodeNoViewController<BatteryDelegate> {

    var containerBatteryView = UIView()
    let batteryView = BatteryView()

    var containerRSSIView = UIView()
    let rssiView = RSSIView()

    let stackView = UIStackView()

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.Battery.Text.title.localized

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        stackView.axis = .vertical
        stackView.spacing = 10.0

        view.addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 10.0),
            equal(\.safeAreaLayoutGuide.bottomAnchor)
        ])

        containerBatteryView = batteryView.embedInView(with: .standardEmbed)
        containerRSSIView = rssiView.embedInView(with: .standardEmbed)

        stackView.addArrangedSubview(containerRSSIView)
        stackView.addArrangedSubview(containerBatteryView)
        stackView.addArrangedSubview(UIView())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerBatteryView.backgroundColor = .white
        containerBatteryView.layer.cornerRadius = 8.0
        containerBatteryView.applyShadow()

        containerRSSIView.backgroundColor = .white
        containerRSSIView.layer.cornerRadius = 8.0
        containerRSSIView.applyShadow()
    }

    override func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateRSSI(with: node.rssi)
        }
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateValue(with: sample)
            BlueManager.shared.readRSSI(for: node)
        }
    }
}
