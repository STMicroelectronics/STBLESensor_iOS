//
//  HeartRateViewController.swift
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

final class HeartRateViewController: DemoNodeNoViewController<HeartRateDelegate> {

    let mHeartImage = UIImageView()
    let mHeartRateLabel = UILabel()
    let mEnergyLabel = UILabel()
    let mRRIntervalLabel = UILabel()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.heartRate.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        mHeartImage.image = ImageLayout.image(with: "heart", in: .module)
        mHeartImage.contentMode = .scaleAspectFit
        
        mHeartRateLabel.text = "Heart Rate: "
        mEnergyLabel.text = "Energy: "
        mRRIntervalLabel.text = "RR Interval: "
        TextLayout.bold.apply(to: mHeartRateLabel)
        TextLayout.text.apply(to: mEnergyLabel)
        TextLayout.text.apply(to: mRRIntervalLabel)
        
        mHeartRateLabel.textAlignment = .center
        mEnergyLabel.textAlignment = .center
        mRRIntervalLabel.textAlignment = .center
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            mHeartImage,
            mHeartRateLabel,
            mEnergyLabel,
            mRRIntervalLabel,
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
            self?.presenter.updateHeartRateUI(with: sample)
        }
    }

}
