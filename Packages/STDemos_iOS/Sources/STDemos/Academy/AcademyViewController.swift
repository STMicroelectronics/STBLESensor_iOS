//
//  AcademyViewController.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class AcademyViewController: DemoNodeNoViewController<AcademyDelegate> {
    
    let estimateLabel = UILabel()
    
    let xLabel = UILabel()
    let yLabel = UILabel()
    let zLabel = UILabel()
    
    let imageView = UIImageView()
    
    override func configure() {
        super.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.enableNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.disableNotification()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Academy Demo"
        
        TextLayout.title2.apply(to: estimateLabel)
        estimateLabel.textAlignment = .center
        
        imageView.contentMode = .scaleAspectFit

        let mainStackView = UIStackView.getVerticalStackView(
            withSpacing: 8.0,
            views: [
                estimateLabel,
                UIView(),
                imageView,
                xLabel,
                yLabel,
                zLabel
            ]
        )
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
        ])
        
        presenter.load()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func manager(
        _ manager: BlueManager,
        didUpdateValueFor node: Node,
        feature: Feature,
        sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        self.presenter.newAccSample(with: sample)
    }
}
