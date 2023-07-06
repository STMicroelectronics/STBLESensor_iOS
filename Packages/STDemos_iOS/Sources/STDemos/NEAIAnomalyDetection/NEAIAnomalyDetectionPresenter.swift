//
//  NEAIAnomalyDetectionPresenter.swift
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
import Toast

final class NEAIAnomalyDetectionPresenter: DemoPresenter<NEAIAnomalyDetectionViewController> {
    public var generalPhaseStatus: PhaseType = .IDLE
    private var gifIsRunning = false
}

// MARK: - NEAIAnomalyDetectionViewControllerDelegate
extension NEAIAnomalyDetectionPresenter: NEAIAnomalyDetectionDelegate {

    func load() {
        demo = .neaiAnomalyDetection
        
        demoFeatures = param.node.characteristics.features(with: Demo.neaiAnomalyDetection.features)
        
        view.configureView()
    }
    
    /** Open / Close NEAI Commands menú */
    func expandOrHideNEAICommands() {
        if(view.neaiCommandArrowBtn.currentImage == UIImage(systemName: "chevron.up")){
            view.neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            view.neaiExpandOrHideStackView.isHidden = true
        } else {
            view.neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            view.neaiExpandOrHideStackView.isHidden = false
        }
    }
    
    /** Handle Start / Stop Button  */
    func startStop() {
        if(generalPhaseStatus != .BUSY){
            if(generalPhaseStatus == .LEARNING || generalPhaseStatus == .DETECTION){
                sendNEAICommand(NEAIAnomalyDetectionCommand.stop)
            } else {
                if (view.learningDetectingSwitch.isOn == false) {
                    sendNEAICommand(NEAIAnomalyDetectionCommand.learning)
                } else if(view.learningDetectingSwitch.isOn == true) {
                    sendNEAICommand(NEAIAnomalyDetectionCommand.detection)
                }
            }
        } else {
            askIfForceStartCommand()
        }
    }
    
    /** Handle Reset Knowledge Button  */
    func resetKnowledge() {
        sendNEAICommand(NEAIAnomalyDetectionCommand.stop)
        self.view.view.makeToast("Reset DONE.", duration: 1.0)
    }
    
    /** Set Learning / Detecting Switch UI */
    func learningDetecting() {
        if (generalPhaseStatus == .LEARNING || generalPhaseStatus == .DETECTION) {
            if(view.learningDetectingSwitch.isOn){
                view.learningDetectingSwitch.isOn = false
            } else {
                view.learningDetectingSwitch.isOn = true
            }
        }
    }

    private func sendNEAICommand(_ command: NEAIAnomalyDetectionCommand) {
        if let neaiFeature = param.node.characteristics.first(with: NEAIAnomalyDetectionFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: neaiFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
    
    private func askIfForceStartCommand() {
        print("ASK FORCE START COMMAND")
        
        let alert = UIAlertController(title: "WARNING!", message: "Resources are busy with another process. Do you want to stop it and start NEAI-Anomaly Detection anyway?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: "START", style: UIAlertAction.Style.destructive, handler: { _ in
            if self.param.node.characteristics.first(with: NEAIAnomalyDetectionFeature.self) != nil {
                if(self.view.learningDetectingSwitch.isOn){
                    self.sendNEAICommand(NEAIAnomalyDetectionCommand.detection)
                    self.view.view.makeToast("Start Detection", duration: 1.0)
                } else {
                    self.sendNEAICommand(NEAIAnomalyDetectionCommand.learning)
                    self.view.view.makeToast("Start Learning", duration: 1.0)
                }
                alert.dismiss(animated: true)
            }
        }))

        self.view.present(alert, animated: true, completion: nil)
    }

    func updateNEAIAnomalyDetectionUI(with sample: AnyFeatureSample?){
        if let sample = sample as? FeatureSample<NEAIAnomalyDetectionData>,
           let data = sample.data {
            
            let phaseData = data.phase.value
            let stateData = data.state.value
            let phaseProgressData = data.phaseProgress.value
            let statusData = data.status.value
            let similarityData = data.similarity.value
            
            view.phaseValue.text = phaseData?.description
            updateUIBasedOnPhaseValue(phase: phaseData ?? .NULL)
            
            if stateData == .NULL {
                view.stateValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
            } else {
                view.stateValue.text = stateData?.description
            }
            
            if phaseProgressData == 255 {
                view.progressValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
                view.progressBar.isHidden = true
            } else {
                view.progressValue.text = "\(phaseProgressData ?? 0)%"
                view.progressBar.isHidden = false
                view.progressBar.setProgress(Float(Float(phaseProgressData ?? 0)/100), animated: true)
            }
            
            if statusData == .NULL {
                view.statusValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
            } else {
                if statusData == .ANOMALY {
                    view.statusImage.image = ImageLayout.image(with: "NEAI_warning", in: .module)
                } else {
                    view.statusImage.image = ImageLayout.image(with: "NEAI_good", in: .module)
                }
                view.statusValue.text = statusData?.description
            }
            
            if similarityData == 255 {
                view.similarityValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
            } else {
                view.similarityValue.text = "\(similarityData ?? 0)%"
            }
        }
    }
    
    private func updateUIBasedOnPhaseValue(phase: PhaseType){
        generalPhaseStatus = phase
        
        if (phase == .IDLE) {
            stopAnimatingLogo()
            view.startBtn.setTitle(Localizer.NeaiAnomalyDetection.Action.start.localized, for: .normal)
            view.resetKnowledgeBtn.isEnabled = false
            view.resetKnowledgeBtn.isUserInteractionEnabled = false
            view.learningDetectingSwitch.isOn = false
            view.learningDetectingSwitch.isEnabled = true
            view.learningDetectingSwitch.isUserInteractionEnabled = true
            view.statusImage.image = .none
            view.progressBar.setProgress(Float(0), animated: true)
            view.progressBar.isHidden = true
        } else if (phase == .IDLE_TRAINED) {
            stopAnimatingLogo()
            view.startBtn.setTitle(Localizer.NeaiAnomalyDetection.Action.start.localized, for: .normal)
            view.resetKnowledgeBtn.isEnabled = true
            view.resetKnowledgeBtn.isUserInteractionEnabled = true
            view.learningDetectingSwitch.isOn = false
            view.learningDetectingSwitch.isEnabled = true
            view.learningDetectingSwitch.isUserInteractionEnabled = true
            view.learningDetectingSwitch.isOn = true
            view.statusImage.image = .none
            view.progressBar.setProgress(Float(0), animated: true)
            view.progressBar.isHidden = true
        } else if(phase == .LEARNING) {
            startAnimatingLogo()
            view.startBtn.setTitle(Localizer.NeaiAnomalyDetection.Action.stop.localized, for: .normal)
            view.resetKnowledgeBtn.isEnabled = false
            view.resetKnowledgeBtn.isUserInteractionEnabled = false
            view.learningDetectingSwitch.isOn = false
            view.learningDetectingSwitch.isEnabled = false
            view.learningDetectingSwitch.isUserInteractionEnabled = false
            view.statusImage.image = .none
            view.progressBar.isHidden = false
        } else if(phase == .DETECTION) {
            startAnimatingLogo()
            view.startBtn.setTitle(Localizer.NeaiAnomalyDetection.Action.stop.localized, for: .normal)
            view.resetKnowledgeBtn.isEnabled = false
            view.resetKnowledgeBtn.isUserInteractionEnabled = false
            view.learningDetectingSwitch.isOn = true
            view.learningDetectingSwitch.isEnabled = false
            view.learningDetectingSwitch.isUserInteractionEnabled = false
            view.progressBar.setProgress(Float(0), animated: true)
            view.progressBar.isHidden = true
        } else if(phase == .BUSY) {
            stopAnimatingLogo()
            view.startBtn.setTitle(Localizer.NeaiAnomalyDetection.Action.start.localized, for: .normal)
            view.resetKnowledgeBtn.isEnabled = false
            view.resetKnowledgeBtn.isUserInteractionEnabled = false
            view.learningDetectingSwitch.isEnabled = true
            view.learningDetectingSwitch.isUserInteractionEnabled = true
            view.statusImage.image = .none
            view.progressBar.setProgress(Float(0), animated: true)
            view.progressBar.isHidden = true
        }
    }

    func startAnimatingLogo() {
        if !(gifIsRunning){
            let neaiGif = UIImage.gifImageWithName("NEAILogoWhite")
            view.logoImageView.image = neaiGif
            gifIsRunning = true
        }
    }
    
    func stopAnimatingLogo() {
        if(gifIsRunning){
            let staticLogo = ImageLayout.image(with: "NEAI_logo", in: .module)
            view.logoImageView.image = staticLogo
            gifIsRunning = false
        }
    }
}
