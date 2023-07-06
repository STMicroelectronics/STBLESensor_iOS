//
//  CarryPositionViewController.swift
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

final class CarryPositionViewController: DemoNodeNoViewController<CarryPositionDelegate> {

    let handImageView = UIImageView()
    let headImageView = UIImageView()
    
    let shirtImageView = UIImageView()
    let trousersImageView = UIImageView()
    
    let deskImageView = UIImageView()
    let armImageView = UIImageView()
    
    var mPositionToImage:[CarryPositionType : UIImageView] = [:]
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.carryPosition.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        handImageView.image = ImageLayout.image(with: "carry_hand", in: .module)
        headImageView.image = ImageLayout.image(with: "carry_head", in: .module)
        shirtImageView.image = ImageLayout.image(with: "carry_shirt", in: .module)
        trousersImageView.image = ImageLayout.image(with: "carry_trousers", in: .module)
        deskImageView.image = ImageLayout.image(with: "carry_desk", in: .module)
        armImageView.image = ImageLayout.image(with: "carry_arm", in: .module)
        
        handImageView.contentMode = .scaleAspectFit
        headImageView.contentMode = .scaleAspectFit
        shirtImageView.contentMode = .scaleAspectFit
        trousersImageView.contentMode = .scaleAspectFit
        deskImageView.contentMode = .scaleAspectFit
        armImageView.contentMode = .scaleAspectFit
        
        handImageView.alpha = 0.3
        headImageView.alpha = 0.3
        shirtImageView.alpha = 0.3
        trousersImageView.alpha = 0.3
        deskImageView.alpha = 0.3
        armImageView.alpha = 0.3
        
        let row1 = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            handImageView,
            headImageView
        ])
        row1.distribution = .fillEqually
        
        let row2 = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            shirtImageView,
            trousersImageView
        ])
        row2.distribution = .fillEqually
        
        let row3 = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            deskImageView,
            armImageView
        ])
        row3.distribution = .fillEqually
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            row1,
            row2,
            row3
        ])
        mainStackView.distribution = .fillEqually
     
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        initCarryPositionMap()
        
        view.makeToast("Carry Detection Started.")
    }
    
    private func initCarryPositionMap () {
        mPositionToImage = [
            .inHand : handImageView,
            .nearHead : headImageView,
            .shirtPocket : shirtImageView,
            .trousersPocket : trousersImageView,
            .onDesk : deskImageView,
            .armSwing : armImageView
        ]
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateCarryPositionUI(with: sample)
        }
    }

    
}
