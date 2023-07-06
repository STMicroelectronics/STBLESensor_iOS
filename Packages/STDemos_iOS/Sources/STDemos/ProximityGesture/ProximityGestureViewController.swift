//
//  ProximityGestureViewController.swift
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

final class ProximityGestureViewController: DemoNodeNoViewController<ProximityGestureDelegate> {

    let proximityGestureTap = UIImageView()
    let proximityGestureLeftArrow = UIImageView()
    let proximityGestureRightArrow = UIImageView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.proximity.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        proximityGestureTap.image = ImageLayout.image(with: "proximity_gesture_tap", in: .module)
        
        proximityGestureLeftArrow.image = ImageLayout.image(with: "gesture_nav_arrow", in: .module)?
            .maskWithColor(color: ColorLayout.secondary.light)?
            .rotate(radians: (.pi*3)/2)
        proximityGestureRightArrow.image = ImageLayout.image(with: "gesture_nav_arrow", in: .module)?
            .maskWithColor(color: ColorLayout.secondary.light)?
            .rotate(radians: .pi/2)
        
        proximityGestureTap.contentMode = .scaleAspectFit
        proximityGestureLeftArrow.contentMode = .scaleAspectFit
        proximityGestureRightArrow.contentMode = .scaleAspectFit
        
        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            proximityGestureLeftArrow,
            proximityGestureRightArrow
        ])
        horizontalStackView.distribution = .fillEqually
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 0, views: [
            proximityGestureTap,
            horizontalStackView
        ])
        mainStackView.distribution = .fillEqually
        
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
            self?.presenter.updateProximityUI(with: sample)
        }
    }

}
