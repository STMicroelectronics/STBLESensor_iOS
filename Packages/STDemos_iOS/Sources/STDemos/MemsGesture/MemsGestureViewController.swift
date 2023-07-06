//
//  MemsGestureViewController.swift
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

final class MemsGestureViewController: DemoNodeNoViewController<MemsGestureDelegate> {

    let glanceImageView = UIImageView()
    let wakeUpImageView = UIImageView()
    let pickUpImageView = UIImageView()
    
    var mGestureToImage: [GestureType : UIImageView] = [:]
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.memsGesture.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        glanceImageView.image = ImageLayout.image(with: "mems_gesture_glance", in: .module)
        pickUpImageView.image = ImageLayout.image(with: "mems_gesture_pickUp", in: .module)
        wakeUpImageView.image = ImageLayout.image(with: "mems_gesture_wakeUp", in: .module)
        
        glanceImageView.contentMode = .scaleAspectFit
        pickUpImageView.contentMode = .scaleAspectFit
        wakeUpImageView.contentMode = .scaleAspectFit
        
        glanceImageView.alpha = 0.3
        pickUpImageView.alpha = 0.3
        wakeUpImageView.alpha = 0.3
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            glanceImageView,
            pickUpImageView,
            wakeUpImageView
        ])
        mainStackView.distribution = .fillEqually
     
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        initGestureImageMap()
        
        view.makeToast("MEMS Gesture Recognition Started.")
    }
    
    private func initGestureImageMap () {
        mGestureToImage = [
            .glance : glanceImageView,
            .pickUp : pickUpImageView,
            .wakeUp : wakeUpImageView
        ]
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateMemsGestureUI(with: sample)
        }
    }

}
