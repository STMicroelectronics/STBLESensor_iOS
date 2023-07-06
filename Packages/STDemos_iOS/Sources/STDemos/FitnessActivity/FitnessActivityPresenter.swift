//
//  FitnessActivityPresenter.swift
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

final class FitnessActivityPresenter: DemoPresenter<FitnessActivityViewController> {
    private static let PULSE_ANIMATION_KEY = "BlueMSFitnessActivityViewController.PulseAnimation"
    private static let PULSE_ANIMATION:CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        animation.values = [1.0,0.8,1.2,1.0]
        animation.keyTimes = [0.0,0.25,0.75,1.0]
        animation.duration = 0.3
        return animation
    }()
}

// MARK: - FitnessActivityViewControllerDelegate
extension FitnessActivityPresenter: FitnessActivityDelegate {

    func load() {
        
        demo = .fitnessActivity
        
        demoFeatures = param.node.characteristics.features(with: Demo.fitnessActivity.features)
        
        view.configureView()
    }

    public func updateFitnessActivityUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<FitnessActivityData>,
           let data = sample.data {
            if let activityType = data.type.value {
                if let activityImage = updateImage(activityType) {
                    view.activityImage.image = activityImage
                    view.activityImage.layer.add(FitnessActivityPresenter.PULSE_ANIMATION, forKey: FitnessActivityPresenter.PULSE_ANIMATION_KEY)
                }
                view.activityTitle.text = "\(activityType.description)"
                view.activityCounter.text = "\(activityType.description) counter: \(String(Int(data.counter.value ?? 0)))"
            }
        }
    }
    
    func changeActivity() {
        var actions: [UIAlertAction] = []
        let activityTypes: [String] = FitnessActivityType.allCases.map{ $0.description }
        for i in 0..<FitnessActivityType.allCases.count {
            actions.append(UIAlertAction.genericButton(activityTypes[i]) { [weak self] _ in
                self?.sendActivityTypeCommand(FitnessActivityType.allCases[i])
            })
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentAlert(from: view.self, title: "Select Activity Type", actions: actions)
    }
    
    func sendActivityTypeCommand(_ command: FitnessActivityType) {
        if let fitnessActivityFeature = param.node.characteristics.first(with: FitnessActivityFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: fitnessActivityFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
    
    private func updateImage(_ activityType: FitnessActivityType) -> UIImage? {
        switch activityType {
            case .bicepCurl:
                return ImageLayout.image(with: "fitness_bicep_curl", in: .module)?.withTintColor(ColorLayout.primary.light)
            case .pushUp:
                return ImageLayout.image(with: "fitness_push_up", in: .module)?.withTintColor(ColorLayout.primary.light)
            case .squat:
                return ImageLayout.image(with: "fitness_squat", in: .module)?.withTintColor(ColorLayout.primary.light)
            case .noActivity:
                return ImageLayout.image(with: "fitness_unknown", in: .module)?.withTintColor(ColorLayout.primary.light)
        }
        
    }
}
