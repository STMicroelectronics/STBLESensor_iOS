//
//  SwitchViewController.swift
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

final class SwitchViewController: DemoNodeNoViewController<SwitchDelegate> {

    var currentSwitchStatus: SwitchType = .switchOff
    let switchLed = UIImageView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.switchDemo.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        let infoLabel = UILabel()
        infoLabel.text = "Click the image to change the status"
        TextLayout.info.apply(to: infoLabel)
        infoLabel.textAlignment = .center
        
        switchLed.image = ImageLayout.image(with: "switch_led_off", in: .module)
        switchLed.setDimensionContraints(width: 300, height: 400)
        switchLed.contentMode = .center
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            infoLabel,
            UIView(),
            switchLed,
            UIView()
        ])
        mainStackView.distribution = .fill
     
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let ledBtnTap = UITapGestureRecognizer(target: self, action: #selector(ledBtnTapped(_:)))
        switchLed.isUserInteractionEnabled = true
        switchLed.addGestureRecognizer(ledBtnTap)
        
        presenter.doInitialRead()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateSwitchUI(with: sample)
        }
    }

}

extension SwitchViewController {
    @objc
    func ledBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.switchStatus()
    }
}
