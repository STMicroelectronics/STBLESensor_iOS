//
//  ActivityRecognitionPresenter.swift
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

final class ActivityRecognitionPresenter: DemoPresenter<ActivityRecognitionViewController> {
    var activityRecognitionSampleDelegate: ActivityRecognitionFirstSampleDelegate?
    public typealias ActivityRecognitionSampleCompletion = (_ sample: ActivityData?) -> Void
}

// MARK: - ActivityRecognitionViewControllerDelegate
extension ActivityRecognitionPresenter: ActivityRecognitionDelegate {

    func load() {
        
        demo = .activityRecognition
        
        demoFeatures = param.node.characteristics.features(with: Demo.activityRecognition.features)
        
        view.configureView()
    }
    
    func doInitialRead() {
        readInitialSample { arData in
            if let data = arData {
                if let activity = data.activity.value {
                    self.displayAlgorithmView(algoID: data.algorithmId.value ?? 0, type: activity)
                }
            }
        }
    }
    
    func updateActivityRecognitionUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<ActivityData>,
           let data = sample.data {
            if let activity = data.activity.value {
                displayAlgorithmView(algoID: data.algorithmId.value ?? 0, type: activity)
            }
        }
    }
    
    private func displayAlgorithmView(algoID: UInt8, type: ActivityType){
        switch algoID {
        case 0:
            if let motionView = view.motionView {
                view.mainView.mainStackView.addArrangedSubview(motionView as! UIView)
                displayActivityType(on: motionView, type)
            }
        case 1:
            if let gpmView = view.gpmView {
                view.mainView.mainStackView.addArrangedSubview(gpmView as! UIView)
                displayActivityType(on: gpmView, type)
            }
        case 2:
            if let ignView = view.ignView {
                view.mainView.mainStackView.addArrangedSubview(ignView as! UIView)
                displayActivityType(on: ignView, type)
            }
        case 3:
            if let mlcView = view.mlcView {
                view.mainView.mainStackView.addArrangedSubview(mlcView as! UIView)
                displayActivityType(on: mlcView, type)
            }
        case 4:
            if let adultPresenceView = view.adultPresenceView {
                view.mainView.mainStackView.addArrangedSubview(adultPresenceView as! UIView)
                displayActivityType(on: adultPresenceView, type)
            }
        default:
            if let motionView = view.motionView {
                view.mainView.mainStackView.addSubview(motionView as! UIView)
                displayActivityType(on: motionView, type)
            }
        }
    }
    
    private func displayActivityType(on arView: ARBaseView ,_ newActivity: ActivityType){
        if let activity = view.mCurrentActivity {
            arView.deselect(type: activity)
        }
        view.mCurrentActivity = newActivity
        arView.select(type: newActivity)
    }
    
    private func readInitialSample(_ completion: @escaping ActivityRecognitionSampleCompletion) {
        if let activityRecognitionFeature = param.node.characteristics.first(with: ActivityFeature.self) {
            activityRecognitionSampleDelegate = ActivityRecognitionFirstSampleDelegate(completion: completion)
            
            guard let activityRecognitionSampleDelegate = activityRecognitionSampleDelegate else { return }
            
            BlueManager.shared.read(feature: activityRecognitionFeature, for: param.node, delegate: activityRecognitionSampleDelegate)
        }
    }
}
