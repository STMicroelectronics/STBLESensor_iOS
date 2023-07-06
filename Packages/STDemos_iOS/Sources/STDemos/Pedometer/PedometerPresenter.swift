//
//  PedometerPresenter.swift
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

final class PedometerPresenter: DemoPresenter<PedometerViewController> {
    private static let STEPS_VALUE_FORMAT = {
        return  NSLocalizedString("Steps: %d",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveMaintenancePresenter.self),
                                  value: "Steps: %d",
                                  comment: "Steps: %d");
    }()
    private static let FREQUENCY_VALUE_FORMAT = {
        return  NSLocalizedString("Frequency: %d %@",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveMaintenancePresenter.self),
                                  value: "Frequency: %d %@",
                                  comment: "Frequency: %d %@");
    }()
    
    private var mImageIsFlip=false;
    private let mFlipImage = CGAffineTransform(
        a: -1, b: 0,
        c: 0,  d: 1,
        tx: 0, ty: 0)
    private let mUnFlipImage = CGAffineTransform.identity;
}

// MARK: - PedometerViewControllerDelegate
extension PedometerPresenter: PedometerDelegate {

    func load() {
        demo = .pedometer
        
        demoFeatures = param.node.characteristics.features(with: Demo.pedometer.features)
        
        view.configureView()
    }

    func updatePedometerUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<PedometerData>,
           let data = sample.data {
            self.animateIcon()
            if let steps = data.steps.value{
                view.pedometerStepsLabel.text = String(format: PedometerPresenter.STEPS_VALUE_FORMAT, steps)
            }
            if let frequency = data.frequency.value {
                view.pedometerFrequencyLabel.text = String(format: PedometerPresenter.FREQUENCY_VALUE_FORMAT, frequency, "steps/min")
            }
        }
    }
    
    private func animateIcon(){
        if((view.pedometerImage.layer.animationKeys()?.isEmpty) ?? true){
            if(mImageIsFlip){
                view.pedometerImage.layer.setAffineTransform(mUnFlipImage)
            }else{
                view.pedometerImage.layer.setAffineTransform(mFlipImage)
            }
            mImageIsFlip = !mImageIsFlip
        }
    }
}
