//
//  MotionAlgorithmsViewController.swift
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

final class MotionAlgorithmsViewController: DemoNodeNoViewController<MotionAlgorithmsDelegate> {
    var currentMotionAlgorithmType = Algorithm.poseEstimation
    
    let motionAlgorithmTitle = UILabel()
    let motionAlgorithmImage = UIImageView()
    let changeMotionAlgorithmBtn = UIButton()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.motionAlgorithm.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        motionAlgorithmTitle.text = "None"
        TextLayout.title.apply(to: motionAlgorithmTitle)
        motionAlgorithmTitle.textAlignment = .center
        
        motionAlgorithmImage.image = ImageLayout.image(with: "fitness_unknown", in: .module)
        
        Buttonlayout.standard.apply(to: changeMotionAlgorithmBtn, text: "Change Algorithm")
        
        let imageStackView = UIStackView.getVerticalStackView(withSpacing: 0, views: [
            UIView(),
            motionAlgorithmImage,
            UIView()
        ])
        imageStackView.distribution = .equalCentering
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            motionAlgorithmTitle,
            imageStackView,
            changeMotionAlgorithmBtn
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let changeMotionAlgorithmTap = UITapGestureRecognizer(target: self, action: #selector(changeMotionAlgorithmTapped(_:)))
        changeMotionAlgorithmBtn.addGestureRecognizer(changeMotionAlgorithmTap)
        
        presenter.sendMotionAlgorithmTypeCommand(currentMotionAlgorithmType)
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateMotionAlgorithmUI(with: sample)
        }
    }
}

extension MotionAlgorithmsViewController {
    @objc
    func changeMotionAlgorithmTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeMotionAlgorithm()
    }
}
