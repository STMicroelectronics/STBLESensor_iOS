//
//  NEAIExtrapolationPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
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
import Toast

final class NEAIExtrapolationPresenter: DemoPresenter<NEAIExtrapolationViewController> {
    public var generalPhaseStatus: NEAIExtrapolationPhaseType = .IDLE
    private var gifIsRunning = false
}

// MARK: - NEAIExtrapolationViewControllerDelegate
extension NEAIExtrapolationPresenter: NEAIExtrapolationDelegate {
    
    func load() {
        demo = .neaiExtrapolation
        
        demoFeatures = param.node.characteristics.features(with: Demo.neaiExtrapolation.features)
        
        view.configureView()
    }
    
    func enableNotification() {
        if let feature = param.node.characteristics.allFeatures().first(where: {feature in feature is NEAIExtrapolationFeature}) {
            BlueManager.shared.enableNotifications(for: param.node, feature: feature)
        }
    }
    
    func disableNotification() {
        if let feature = param.node.characteristics.allFeatures().first(where: {feature in feature is NEAIExtrapolationFeature}) {
            BlueManager.shared.disableNotifications(for: param.node, feature: feature)
        }
    }
    
    func expandOrHideNEAICommands() {
        if(view.neaiCommandArrowBtn.currentImage == UIImage(systemName: "chevron.up")){
            view.neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            view.neaiExpandOrHideStackView.isHidden = true
        } else {
            view.neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            view.neaiExpandOrHideStackView.isHidden = false
        }
    }
    
    func startExtrapolation() {
        if (generalPhaseStatus != .BUSY) {
            sendNEAICommand(NEAIExtrapolationCommand.start)
            self.view.view.makeToast("Start Extrapolation", duration: 1.0)
        } else {
            askIfForceStartCommand()
        }
    }
    
    
    func howRemoveStubMode() {
        explainHowRemoveStubMode()
    }
    
    func stopExtrapolation() {
        sendNEAICommand(NEAIExtrapolationCommand.stop)
        self.view.view.makeToast("Stop Extrapolation", duration: 1.0)
    }
    
    
    func updateNEAIExtrapolationUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<NEAIExtrapolationData>,
           let data = sample.data {
            
            let phaseValue = data.neaiExtrapolation.value?.phase
            let stateValue = data.neaiExtrapolation.value?.state
            let target = data.neaiExtrapolation.value?.target
            let unit = data.neaiExtrapolation.value?.unit
            let stub = data.neaiExtrapolation.value?.stub
            
            if let phase = phaseValue {
                if phase == NEAIExtrapolationPhaseType.NULL {
                    self.view.phaseValue.text = "---"
                } else {
                    self.view.phaseValue.text = phase.description
                    self.updateUiBasedOnPhase(phase: phase)
                }
            }
            
            if stateValue == NEAIExtrapolationStateType.NULL {
                self.view.stateValue.text = "---"
            } else {
                self.view.stateValue.text = stateValue?.description
            }
            
            if let stub {
                self.view.stubView.isHidden = !stub
            } else {
                self.view.stubView.isHidden = false
            }
            
            if target == nil {
                self.view.targetSV.isHidden = true
                self.view.targetUnitValue.text = " "
            } else {
                self.view.targetSV.isHidden = false
 
                var stringTarget = "\(target!)"
                if unit != nil {
                    stringTarget += " [\(unit!)]"
                }
                self.view.targetUnitValue.text = stringTarget
            }
        }
    }
}

extension NEAIExtrapolationPresenter {
    
    private func sendNEAICommand(_ command: NEAIExtrapolationCommand) {
        if let neaiExtrapolationFeature = param.node.characteristics.first(with: NEAIExtrapolationFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: neaiExtrapolationFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
    
    private func askIfForceStartCommand() {
        let alert = UIAlertController(title: "WARNING!", message: "Resources are busy with another process. Do you want to stop it and start NEAI-Extrapolation anyway?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "START", style: UIAlertAction.Style.destructive, handler: { _ in
            if self.param.node.characteristics.first(with: NEAIExtrapolationFeature.self) != nil {
                self.sendNEAICommand(NEAIExtrapolationCommand.start)
                self.view.view.makeToast("Start Extrapolation", duration: 1.0)
                alert.dismiss(animated: true)
            }
        }))
        
        self.view.present(alert, animated: true, completion: nil)
    }
    
    private func explainHowRemoveStubMode() {
        let alert = UIAlertController(title: "Demo Mode", message: "This is a demo extrapolation library, its results have no sense. To easily develop your own real AI libraries, use the free ST tool:\nNanoEdge AI Studio.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        self.view.present(alert, animated: true, completion: nil)
    }
    
    private func updateUiBasedOnPhase(phase: NEAIExtrapolationPhaseType){
        generalPhaseStatus = phase
        if (phase == .IDLE) {
            self.view.startBtn.isEnabled = true
            self.view.startBtn.isUserInteractionEnabled = true
            self.view.stopBtn.isEnabled = false
            self.view.stopBtn.isUserInteractionEnabled = false
            stopAnimatingLogo()
        } else if (phase == .EXTRAPOLATION) {
            self.view.startBtn.isEnabled = false
            self.view.startBtn.isUserInteractionEnabled = false
            self.view.stopBtn.isEnabled = true
            self.view.stopBtn.isUserInteractionEnabled = true
            startAnimatingLogo()
        } else if (phase == .BUSY) {
            self.view.startBtn.isEnabled = true
            self.view.startBtn.isUserInteractionEnabled = true
            self.view.stopBtn.isEnabled = false
            self.view.stopBtn.isUserInteractionEnabled = false
            stopAnimatingLogo()
        }
    }
    
    private func startAnimatingLogo() {
        if !(gifIsRunning){
            let neaiGif = UIImage.gifImageWithName("NEAILogoWhite")
            view.logoImageView.image = neaiGif
            gifIsRunning = true
        }
    }
    
    private func stopAnimatingLogo() {
        if(gifIsRunning){
            let staticLogo = ImageLayout.image(with: "NEAI_logo", in: .module)
            view.logoImageView.image = staticLogo
            gifIsRunning = false
        }
    }
}
