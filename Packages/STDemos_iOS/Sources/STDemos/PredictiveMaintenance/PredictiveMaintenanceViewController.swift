//
//  PredictiveMaintenanceViewController.swift
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

final class PredictiveMaintenanceViewController: DemoNodeNoViewController<PredictiveMaintenanceDelegate> {

    var containerSpeedStatusView = UIView()
    let speedStatusView = PredictiveMaintenanceBaseView()
    
    var containerAccPeakStatusView = UIView()
    let accPeakStatusView = PredictiveMaintenanceBaseView()
    
    var containerFrequencyDomainStatusView = UIView()
    let frequencyDomainStatusView = PredictiveMaintenanceBaseView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.predictiveMaintenance.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        containerSpeedStatusView = speedStatusView.embedInView(with: .standard)
        containerAccPeakStatusView = accPeakStatusView.embedInView(with: .standardEmbed)
        containerFrequencyDomainStatusView = frequencyDomainStatusView.embedInView(with: .standardEmbed)

        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            containerSpeedStatusView,
            containerAccPeakStatusView,
            containerFrequencyDomainStatusView,
        ])
        mainStackView.distribution = .fill
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
        
        setupUILabels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerSpeedStatusView.backgroundColor = .white
        containerSpeedStatusView.layer.cornerRadius = 8.0
        containerSpeedStatusView.applyShadow()

        containerAccPeakStatusView.backgroundColor = .white
        containerAccPeakStatusView.layer.cornerRadius = 8.0
        containerAccPeakStatusView.applyShadow()

        containerFrequencyDomainStatusView.backgroundColor = .white
        containerFrequencyDomainStatusView.layer.cornerRadius = 8.0
        containerFrequencyDomainStatusView.applyShadow()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updatePredictiveMaintenanceUI(with: sample)
        }
    }
    
    private func setupUILabels() {
        speedStatusView.title.text = "Speed Status"
        
        accPeakStatusView.title.text = "Acceleration Peak Status"
        
        frequencyDomainStatusView.title.text = "Frequency Domain Status"
    }

}
