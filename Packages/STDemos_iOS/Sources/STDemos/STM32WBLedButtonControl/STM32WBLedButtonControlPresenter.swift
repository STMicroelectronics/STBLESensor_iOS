//
//  STM32WBLedButtonControlPresenter.swift
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

final class STM32WBLedButtonControlPresenter: DemoPresenter<STM32WBLedButtonControlViewController> {
    
    var rssi: Int

    public init(rssi: Int, param: DemoParam<Void>) {
        self.rssi = rssi
        super.init(param: param)
    }
    
    private static let DEVICE_TITLE_FORMAT = {
        return  NSLocalizedString("Device Server %d",
                                  tableName: nil,
                                  bundle: .module,
                                  value: "Device Server %d",
                                  comment: "Device Server %d")
    }()
    
    fileprivate let mPulseAnimation:CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        animation.values = [1.0,0.8,1.2,1.0]
        animation.keyTimes = [0.0,0.25,0.75,1.0]
        animation.duration = 0.3
        return animation
    }()
    
    private static let BELL_ANIMATION_KEY = "STM32WBLedButtonViewController.BELL_ANIMATION_KEY"
    
    private static let BUTTON_EVENT_FORMAT = {
        return  NSLocalizedString("Button pressed: %@ { %d }",
                                  tableName: nil,
                                  bundle: .module,
                                  value: "Button pressed: %@ { %d }",
                                  comment: "Button pressed: %@ { %d }")
    }()
    
    private var mLedStatus = false
}

// MARK: - STM32WBLedButtonControlViewControllerDelegate
extension STM32WBLedButtonControlPresenter: STM32WBLedButtonControlDelegate {

    func load() {
        demo = .ledControl
        
        demoFeatures = param.node.characteristics.features(with: Demo.ledControl.features)
        
        view.configureView()
        
        if param.node.type == .wbaBoard {
            showLedController(1)
        }
    }
    
    func ledTapped() {
        if(mLedStatus){
            sendControlLedTypeCommand(ControlLedCommand.switchOffLed)
            view.ledImage.image = ImageLayout.image(with: "switch_led_off", in: .module)
        } else {
            sendControlLedTypeCommand(ControlLedCommand.switchOnLed)
            view.ledImage.image = ImageLayout.image(with: "switch_led_on", in: .module)
        }
        mLedStatus = !mLedStatus
    }
    
    private func sendControlLedTypeCommand(_ command: ControlLedCommand) {
        if let controlLedFeature = param.node.characteristics.first(with: ControlLedFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: controlLedFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
    
    func updateLedControlUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<STM32SwitchStatusData>,
           let data = sample.data {
            if(view.mCurrentDevice == nil && data.deviceId.value != nil) {
                if let deviceId = data.deviceId.value {
                    showLedController(Int(deviceId))
                }
            }
            let status = data.status.value
            let eventTime = DateFormatter.localizedString(from: sample.notificationTime, dateStyle: .none, timeStyle: .medium)
            if let status = status {
                let eventString = String(format:STM32WBLedButtonControlPresenter.BUTTON_EVENT_FORMAT, eventTime, status)
                DispatchQueue.main.async {
                    self.view.alarmLabel.text = eventString
                    self.view.alarmImage.layer.add(self.mPulseAnimation, forKey: STM32WBLedButtonControlPresenter.BELL_ANIMATION_KEY)
                }
            }
        }
    }
    
    private func showLedController(_ deviceId: Int){
        self.view.deviceTitle.isHidden = false
        let deviceName = String(format:STM32WBLedButtonControlPresenter.DEVICE_TITLE_FORMAT, deviceId)
        self.view.deviceTitle.text = deviceName
        self.view.info1Label.isHidden=true
        self.view.ledImage.isHidden = false
        self.view.info2Label.isHidden = false
    }
    
    func updateRSSI(with rssi: Int?) {
        view.rssiLabel.text = "RSSI: \(rssi ?? 0)dBm"
    }

}
