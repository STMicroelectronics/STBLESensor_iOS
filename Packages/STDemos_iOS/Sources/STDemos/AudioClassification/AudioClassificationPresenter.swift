//
//  AudioClassificationPresenter.swift
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

final class AudioClassificationPresenter: DemoPresenter<AudioClassificationViewController> {
    var audioClassificationSampleDelegate: AudioClassificationFirstSampleDelegate?
    public typealias AudioClassificationSampleCompletion = (_ sample: AudioClassificationData?) -> Void
}

// MARK: - AudioClassificationViewControllerDelegate
extension AudioClassificationPresenter: AudioClassificationDelegate {

    func load() {
        demo = .audioClassification
        
        demoFeatures = param.node.characteristics.features(with: Demo.audioClassification.features)
        
        view.configureView()
    }

    func doInitialRead() {
        readInitialSample { audioClassificationData in
            if let data = audioClassificationData {
                if let audioClass = data.audioClass?.value {
                    self.displayAlgorithmView(algoID: data.algorithm?.value ?? 0, type: audioClass)
                }
            }
        }
    }
    
    func updateAudioClassificationUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<AudioClassificationData>,
           let data = sample.data {
            if let audioClass = data.audioClass?.value {
                displayAlgorithmView(algoID: data.algorithm?.value ?? 0, type: audioClass)
            }
        }
    }
    
    private func displayAlgorithmView(algoID: UInt8, type: AudioClass){
        switch algoID {
        case 0:
            if let audioSceneView = view.audioSceneView {
                view.mainView.mainStackView.addArrangedSubview(audioSceneView as! UIView)
                displayActivityType(on: audioSceneView, type)
            }
        case 1:
            if let babyCryingView = view.babyCryingView {
                view.mainView.mainStackView.addArrangedSubview(babyCryingView as! UIView)
                displayActivityType(on: babyCryingView, type)
            }
        default:
            if let audioSceneView = view.audioSceneView {
                view.mainView.mainStackView.addArrangedSubview(audioSceneView as! UIView)
                displayActivityType(on: audioSceneView, type)
            }
        }
    }
    
    private func displayActivityType(on audioClassView: BaseAudioClassView ,_ newAudioClass: AudioClass){
        if let audioClass = view.mCurrentAudioClass {
            audioClassView.deselect(type: audioClass)
        }
        view.mCurrentAudioClass = newAudioClass
        audioClassView.select(type: newAudioClass)
    }
    
    private func readInitialSample(_ completion: @escaping AudioClassificationSampleCompletion) {
        if let audioClassificationFeature = param.node.characteristics.first(with: AudioClassificationFeature.self) {
            audioClassificationSampleDelegate = AudioClassificationFirstSampleDelegate(completion: completion)
            
            guard let audioClassificationSampleDelegate = audioClassificationSampleDelegate else { return }
            
            BlueManager.shared.read(feature: audioClassificationFeature, for: param.node, delegate: audioClassificationSampleDelegate)
        }
    }
    
}
