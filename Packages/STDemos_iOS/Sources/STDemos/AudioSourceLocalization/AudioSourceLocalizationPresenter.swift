//
//  AudioSourceLocalizationPresenter.swift
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

final class AudioSourceLocalizationPresenter: DemoPresenter<AudioSourceLocalizationViewController> {

}

// MARK: - AudioSourceLocalizationViewControllerDelegate
extension AudioSourceLocalizationPresenter: AudioSourceLocalizationDelegate {

    func load() {
        
        demo = .audioSourceLocalization
        
        demoFeatures = param.node.characteristics.features(with: Demo.audioSourceLocalization.features)
        
        view.configureView()
        
        view.mainView.mBoardImage.image = getBoardSchemaImage(baseOnNodeType: param.node.type)
        if(param.node.type == .nucleo){
            view.mainView.mBoardImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        }
    }
    
    func updateAudioSourceLocalizationUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<DirectionOfArrivalData>,
           let data = sample.data {
            if let angle = data.angle.value {
                if(angle>0) {
                    DispatchQueue.main.async {
                        self.view.mainView.mNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(AudioSourceLocalizationPresenter.degreeToRad(Float(angle))))
                        self.view.mainView.mDirectionLabel.text = "Angle: \(angle)°"
                    }
                }
            }
        }
    }
    
    private static func degreeToRad(_ angle:Float) -> Float{
        return angle * Float.pi/180.0
    }

    func setSensitivity() {
        if view.mainView.sensitivitySwitch.isOn {
            sendSourceLocCommand(DirectionOfArrivalCommand.changeSensitivity(sentivity: .highSensitivity))
        } else {
            sendSourceLocCommand(DirectionOfArrivalCommand.changeSensitivity(sentivity: .lowSensitivity))
        }
    }
    
    private func sendSourceLocCommand(_ command: DirectionOfArrivalCommand) {
        if let sourceLocFeature = param.node.characteristics.first(with: DirectionOfArrivalFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: sourceLocFeature
            )
            
        }
    }
    
    func getBoardSchemaImage(baseOnNodeType nodeType: NodeType) -> UIImage? {
        guard let schemaImageName = nodeType.schemaImageName else { return nil }
        return UIImage(named: schemaImageName, in: STUI.bundle, compatibleWith: nil)
    }
}
