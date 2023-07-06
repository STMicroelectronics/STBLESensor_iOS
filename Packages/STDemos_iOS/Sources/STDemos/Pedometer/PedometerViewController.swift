//
//  PedometerViewController.swift
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

final class PedometerViewController: DemoNodeNoViewController<PedometerDelegate> {

    let pedometerImage = UIImageView()
    let pedometerStepsLabel = UILabel()
    let pedometerFrequencyLabel = UILabel()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.pedometer.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        pedometerImage.image = ImageLayout.image(with: "pedometer", in: .module)
        
        pedometerStepsLabel.text = "Steps: 0"
        TextLayout.bold.apply(to: pedometerStepsLabel)
        pedometerStepsLabel.textAlignment = .center
        
        TextLayout.info.apply(to: pedometerFrequencyLabel)
        pedometerFrequencyLabel.textAlignment = .center
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            pedometerImage,
            pedometerStepsLabel,
            pedometerFrequencyLabel,
            UIView()
        ])
        mainStackView.distribution = .fill
     
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updatePedometerUI(with: sample)
        }
    }

}
