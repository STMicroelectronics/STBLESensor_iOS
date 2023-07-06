//
//  HeartRatePresenter.swift
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

final class HeartRatePresenter: DemoPresenter<HeartRateViewController> {
    
    private static let PULSE_ANIMATION_KEY = "HeartRatePresenter.Pulse"
    
    private let mPulseAnimation:CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        animation.values = [1.0,0.8,1.2,1.0]
        animation.keyTimes = [0.0,0.25,0.75,1.0]
        animation.duration = 0.3
        return animation
    }()
    
    private static let RATE_FORMAT:String = {
        return  NSLocalizedString(
            "%d %@",
            tableName: nil,
            bundle: .module,
            value: "%d %@",
            comment: "%d %@")
    }()
    
    private static let ENERGY_FORMAT:String = {
        return  NSLocalizedString(
            "Energy: %d %@",
            tableName: nil,
            bundle: .module,
            value: "Energy: %d %@",
            comment: "Energy: %d %@")
    }()
    
    private static let RR_INTERVAL_FORMAT:String = {
        return  NSLocalizedString(
            "RR Interval: %.2f %@",
            tableName: nil,
            bundle: .module,
            value: "RR Interval: %.2f %@",
            comment: "RR Interval: %.2f %@")
    }()
}

// MARK: - HeartRateViewControllerDelegate
extension HeartRatePresenter: HeartRateDelegate {

    func load() {
        demo = .heartRate
        
        demoFeatures = param.node.characteristics.features(with: Demo.heartRate.features)
        
        view.configureView()
    }

    func updateHeartRateUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<HeartRateData>,
           let data = sample.data {
            if let rate = data.heartRate.value {
                updateRate(rate, data.heartRate.uom ?? "")
            }
            if let energy = data.energyExpended.value {
                updateEnergy(energy, data.energyExpended.uom ?? "")
            }
            if let rrInterval = data.rrInterval.value {
                updateRRInterval(rrInterval, data.rrInterval.uom ?? "")
            }
        }
    }
    
    private func updateRate(_ rate: Int32, _ uom: String) {
        if (rate>0){
            view.mHeartRateLabel.text = String(format: HeartRatePresenter.RATE_FORMAT, rate, uom)
            view.mHeartImage.image = ImageLayout.image(with: "heart", in: .module)
            view.mHeartImage.layer.add(mPulseAnimation, forKey: HeartRatePresenter.PULSE_ANIMATION_KEY)
        } else {
            view.mHeartImage.image = ImageLayout.image(with: "heart_gray", in: .module)
            view.mHeartRateLabel.text = nil
        }
    }
    
    private func updateEnergy(_ energy: Int32, _ uom: String) {
        if(energy>0){
            view.mEnergyLabel.text = String(format: HeartRatePresenter.ENERGY_FORMAT, energy, uom)
        } else {
            view.mEnergyLabel.text = nil
        }
    }
    
    private func updateRRInterval(_ rrInterval: Float, _ uom: String) {
        if(rrInterval.isNaN) {
            view.mRRIntervalLabel.text = nil
        } else {
            view.mRRIntervalLabel.text = String(format: HeartRatePresenter.RR_INTERVAL_FORMAT, rrInterval, uom)
        }
    }
}
