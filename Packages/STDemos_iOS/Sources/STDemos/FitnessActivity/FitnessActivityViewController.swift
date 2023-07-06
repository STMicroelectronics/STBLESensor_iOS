//
//  FitnessActivityViewController.swift
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

final class FitnessActivityViewController: DemoNodeNoViewController<FitnessActivityDelegate> {
    
    let stackView = UIStackView()
    
    let activityTitle = UILabel()
    let activityImage = UIImageView()
    let activityCounter = UILabel()
    let changeActivityBtn = UIButton()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.fitnessActivity.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        activityTitle.text = "Unknown"
        TextLayout.title.apply(to: activityTitle)
        activityTitle.textAlignment = .center
        
        activityImage.image = ImageLayout.image(with: "fitness_unknown", in: .module)
        
        activityCounter.text = "Reps: 0"
        TextLayout.subtitle.size(20.0).apply(to: activityCounter)
        activityCounter.textAlignment = .center
        
        Buttonlayout.standard.apply(to: changeActivityBtn, text: "Change Activity")
        
        let imageStackView = UIStackView.getVerticalStackView(withSpacing: 0, views: [
            UIView(),
            activityImage,
            UIView()
        ])
        imageStackView.distribution = .equalCentering
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            activityTitle,
            imageStackView,
            activityCounter,
            changeActivityBtn
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let changeActivityTap = UITapGestureRecognizer(target: self, action: #selector(changeActivityTapped(_:)))
        changeActivityBtn.addGestureRecognizer(changeActivityTap)
        
        presenter.sendActivityTypeCommand(.bicepCurl)
        
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateFitnessActivityUI(with: sample)
        }
    }

}

extension FitnessActivityViewController {
    @objc
    func changeActivityTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeActivity()
    }
}

