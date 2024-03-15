//
//  MotorControlViewController.swift
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

final class MotorControlViewController: BaseNoViewController<MotorControlDelegate> {

    var containerMotorInformationView = UIView()
    let motorInformationView = MotorInformationView()
    
    var containerSlowTelemetriesView = UIView()
    let slowTelemetriesView = SlowMotorTelemetriesView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        containerMotorInformationView = motorInformationView.embedInView(with: .standard)
        containerSlowTelemetriesView = slowTelemetriesView.embedInView(with: .standard)
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            containerMotorInformationView, 
            containerSlowTelemetriesView
        ])
        mainStackView.distribution = .fill
        
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerMotorInformationView.backgroundColor = .white
        containerMotorInformationView.layer.cornerRadius = 8.0
        containerMotorInformationView.applyShadow()
        
        containerSlowTelemetriesView.backgroundColor = .white
        containerSlowTelemetriesView.layer.cornerRadius = 8.0
        containerSlowTelemetriesView.applyShadow()
    }

}
