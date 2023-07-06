//
//  ToFMultiObjectPresenter.swift
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

final class ToFMultiObjectPresenter: DemoPresenter<ToFMultiObjectViewController> {
    
}

// MARK: - ToFMultiObjectViewControllerDelegate
extension ToFMultiObjectPresenter: ToFMultiObjectDelegate {

    func load() {
        
        demo = .tofMultiObject
        
        demoFeatures = param.node.characteristics.features(with: Demo.tofMultiObject.features)
        
        view.configureView()
    }
    
    func updateToFUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<ToFMultiObjectData>,
           let data = sample.data {
            
            if !view.isPresenceDetectionModeActivated {
                showObjectDetectionViews()
                if let numberOfObject = data.numberOfObjectsFound.value {
                    if numberOfObject == 0{
                        view.objectView.objectsImage.image = ImageLayout.image(with: "TOF_search", in: .module)
                    } else {
                        view.objectView.objectsImage.image = ImageLayout.image(with: "TOF_objects", in: .module)
                    }
                    if let numberOfObjectsDescription = data.numberOfObjectssFoundString {
                        view.objectView.objectDescription.text = numberOfObjectsDescription
                    }
                }
                
                if let obj1Distance = data.objOne.value {
                    if obj1Distance == 0 {
                        view.containerDistance1View.isHidden = true
                    } else {
                        view.containerDistance1View.isHidden = false
                        view.distance1View.title.text = "Object 1"
                        view.distance1View.value.text = "\(obj1Distance) [mm]"
                        view.distance1View.progress.setProgress(Float(Float(obj1Distance)/4000), animated: true)
                    }
                }
                
                if let obj2Distance = data.objTwo.value {
                    if obj2Distance == 0 {
                        view.containerDistance2View.isHidden = true
                    } else {
                        view.containerDistance2View.isHidden = false
                        view.distance2View.title.text = "Object 2"
                        view.distance2View.value.text = "\(obj2Distance) [mm]"
                        view.distance2View.progress.setProgress(Float(Float(obj2Distance)/4000), animated: true)
                    }
                }
                
                if let obj3Distance = data.objThree.value {
                    if obj3Distance == 0 {
                        view.containerDistance3View.isHidden = true
                    } else {
                        view.containerDistance3View.isHidden = false
                        view.distance3View.title.text = "Object 3"
                        view.distance3View.value.text = "\(obj3Distance) [mm]"
                        view.distance3View.progress.setProgress(Float(Float(obj3Distance)/4000), animated: true)
                    }
                }
                
                if let obj4Distance = data.objFour.value {
                    if obj4Distance == 0 {
                        view.containerDistance4View.isHidden = true
                    } else {
                        view.containerDistance4View.isHidden = false
                        view.distance4View.title.text = "Object 4"
                        view.distance4View.value.text = "\(obj4Distance) [mm]"
                        view.distance4View.progress.setProgress(Float(Float(obj4Distance)/4000), animated: true)
                    }
                }
            } else {
                hideObjectDetectionViews()
                if let numberOfPresence = data.numberOfPresencesFound.value {
                    view.presenceView.presenceDescription.text = data.numberOfPresencesFoundString
                    if numberOfPresence == 0 {
                        view.presenceView.presenceImage.image = ImageLayout.image(with: "TOF_not_presence", in: .module)
                    } else {
                        view.presenceView.presenceImage.image = ImageLayout.image(with: "TOF_presence", in: .module)
                    }
                }
            }
        }
    }
    
    func switchMode() {
        let userDefaults = UserDefaults.standard
        
        if !view.isPresenceDetectionModeActivated {
            view.isPresenceDetectionModeActivated = true
            userDefaults.set(view.isPresenceDetectionModeActivated, forKey: "isPresenceDetectionModeActivated")
            sendToFCommand(ToFCommand.enablePresenceDetection)
            hideObjectDetectionViews()
        } else {
            view.isPresenceDetectionModeActivated = false
            userDefaults.set(view.isPresenceDetectionModeActivated, forKey: "isPresenceDetectionModeActivated")
            sendToFCommand(ToFCommand.disablePresenceDetection)
            showObjectDetectionViews()
        }
    }
    
    private func sendToFCommand(_ command: ToFCommand) {
        if let tofMultiObjectFeature = param.node.characteristics.first(with: ToFMultiObjectFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: tofMultiObjectFeature
            )
            
        }
    }
    
    private func hideObjectDetectionViews() {
        view.selector.setOn(true, animated: true)
        view.containerPresenceView.isHidden = false
        view.containerObjectView.isHidden = true
        view.containerDistance1View.isHidden = true
        view.containerDistance2View.isHidden = true
        view.containerDistance3View.isHidden = true
        view.containerDistance4View.isHidden = true
    }
    
    private func showObjectDetectionViews() {
        view.selector.setOn(false, animated: true)
        view.containerPresenceView.isHidden = true
        view.containerObjectView.isHidden = false
        view.containerDistance1View.isHidden = false
        view.containerDistance2View.isHidden = false
        view.containerDistance3View.isHidden = false
        view.containerDistance4View.isHidden = false
    }
}
