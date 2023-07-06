//
//  STM32WBLedButtonControlViewController.swift
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

final class STM32WBLedButtonControlViewController: DemoNodeNoViewController<STM32WBLedButtonControlDelegate> {
    
    var mCurrentDevice:Int?
    
    let deviceTitle = UILabel()
    
    let rrsiImage = UIImageView()
    let alarmImage = UIImageView()
    let rssiLabel = UILabel()
    let alarmLabel = UILabel()
    
    let info1Label = UILabel()
    let ledImage = UIImageView()
    let info2Label = UILabel()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.ledControl.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        TextLayout.title2.apply(to: deviceTitle)
        deviceTitle.textAlignment = .center
        deviceTitle.isHidden = true
        
        rrsiImage.image = ImageLayout.image(with: "stm32wb_signal_strength", in: .module)
        rrsiImage.setDimensionContraints(height: 60)
        alarmImage.image = ImageLayout.image(with: "stm32wb_bell_ring", in: .module)
        alarmImage.setDimensionContraints(height: 60)
        
        rssiLabel.text = "Waiting ..."
        alarmLabel.text = "No alarm recived"
        
        info1Label.text = "Press SW1 button to identify the board"
        ledImage.image = ImageLayout.image(with: "switch_led_off", in: .module)
        ledImage.contentMode = .center
        info2Label.text = "Click on the image to change the led status"
        
        info1Label.textAlignment = .center
        TextLayout.info.apply(to: info2Label)
        info2Label.textAlignment = .center
        
        ledImage.isHidden = true
        info2Label.isHidden = true
        
        let rssiHorizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            rrsiImage,
            rssiLabel,
            UIView()
        ])
        rssiHorizontalSV.distribution = .fill
        
        let alarmHorizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            alarmImage,
            alarmLabel,
            UIView()
        ])
        alarmHorizontalSV.distribution = .fill
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            deviceTitle,
            rssiHorizontalSV,
            alarmHorizontalSV,
            info1Label,
            UIView(),
            ledImage,
            UIView(),
            info2Label
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let ledTap = UITapGestureRecognizer(target: self, action: #selector(ledTapped(_:)))
        ledImage.isUserInteractionEnabled = true
        ledImage.addGestureRecognizer(ledTap)
        
    }

    override func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateRSSI(with: node.rssi)
        }
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateLedControlUI(with: sample)
            BlueManager.shared.readRSSI(for: node)
        }
    }
}

extension STM32WBLedButtonControlViewController {
    @objc
    func ledTapped(_ sender: UITapGestureRecognizer) {
        presenter.ledTapped()
    }
}
