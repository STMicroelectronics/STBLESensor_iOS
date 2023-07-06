//
//  MotionAlgorithmsPresenter.swift
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

final class MotionAlgorithmsPresenter: DemoPresenter<MotionAlgorithmsViewController> {
    
}

// MARK: - MotionAlgorithmsViewControllerDelegate
extension MotionAlgorithmsPresenter: MotionAlgorithmsDelegate {

    func load() {
        
        demo = .motionAlgorithm
        
        demoFeatures = param.node.characteristics.features(with: Demo.motionAlgorithm.features)
        
        view.configureView()
    }

    public func updateMotionAlgorithmUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<MotionAlgorithmData>,
           let data = sample.data {
            if let motionAlgorithm = data.algorithm.value {
                view.motionAlgorithmTitle.text = motionAlgorithm.description
                if let motionAlgorithmImage = updateMotionAlgorithmImage(type: motionAlgorithm, data: data) {
                    view.motionAlgorithmImage.image = motionAlgorithmImage
                }
            }
        }
    }
    
    func changeMotionAlgorithm() {
        var actions: [UIAlertAction] = []
        let motionAlgorithmTypes: [String] = Algorithm.allCases.map{ $0.description }
        for i in 0..<Algorithm.allCases.count {
            actions.append(UIAlertAction.genericButton(motionAlgorithmTypes[i]) { [weak self] _ in
                self?.sendMotionAlgorithmTypeCommand(Algorithm.allCases[i])
            })
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentAlert(from: view.self, title: "Select the Algorithm", actions: actions)
    }
    
    func sendMotionAlgorithmTypeCommand(_ command: Algorithm) {
        if let motionAlgorithmFeature = param.node.characteristics.first(with: MotionAlgorithmFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: motionAlgorithmFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
    
    private func updateMotionAlgorithmImage(type: Algorithm, data: MotionAlgorithmData) -> UIImage? {
        switch type {
        case .none:
            return ImageLayout.image(with: "fitness_unknown", in: .module)
        case .poseEstimation:
            return data.getPoseEstimation()?.icon
        case .deskTypeDetection:
            return data.getDetectedDeskType()?.icon
        case .verticalContext:
            return data.getVerticalContext()?.icon
        }
        
    }
    
}
