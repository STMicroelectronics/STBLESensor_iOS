//
//  SwitchPresenter.swift
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
import STCore

final class SwitchPresenter: DemoPresenter<SwitchViewController> {
    var switchSampleDelegate: SwitchFirstSampleDelegate?
    public typealias SwitchSampleCompletion = (_ sample: SwitchData?) -> Void
}

// MARK: - SwitchViewControllerDelegate
extension SwitchPresenter: SwitchDelegate {

    func load() {
        view.configureView()
        
        demo = .switchDemo
        
        demoFeatures = param.node.characteristics.features(with: Demo.switchDemo.features)
    }
    
    func updateSwitchUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<SwitchData>,
           let data = sample.data {
            if let status = data.status.value {
                updateSwitchLedImage(status: status)
            }
        }
    }
    
    func switchStatus() {
        if(view.currentSwitchStatus == .switchOff) {
            sendSwitchTypeCommand(.switchOn)
            view.currentSwitchStatus = .switchOn
        } else {
            sendSwitchTypeCommand(.switchOff)
            view.currentSwitchStatus = .switchOff
        }
    }
    
    func doInitialRead() {
        readInitialSample { switchData in
            if let data = switchData {
                if let status = data.status.value {
                    self.updateSwitchLedImage(status: status)
                }
            }
        }
    }
    
    private func readInitialSample(_ completion: @escaping SwitchSampleCompletion) {
        if let switchFeature = param.node.characteristics.first(with: SwitchFeature.self) {
            switchSampleDelegate = SwitchFirstSampleDelegate(completion: completion)
            
            guard let switchSampleDelegate = switchSampleDelegate else { return }
            
            BlueManager.shared.read(feature: switchFeature, for: param.node, delegate: switchSampleDelegate)
        }
    }
    
    private func updateSwitchLedImage(status: UInt8) {
        if(status == 0x01) {
            view.switchLed.image = ImageLayout.image(with: "switch_led_on", in: .module)
        } else {
            view.switchLed.image = ImageLayout.image(with: "switch_led_off", in: .module)
        }
    }
    
    private func sendSwitchTypeCommand(_ command: SwitchType) {
        if let switchFeature = param.node.characteristics.first(with: SwitchFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: switchFeature
            )
            
            Logger.debug(text: command.description)
        }
    }

}
