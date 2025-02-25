//
//  NEAIClassificationPresenter.swift
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

final class NEAIClassificationPresenter: DemoPresenter<NEAIClassificationViewController> {
    public var generalPhaseStatus: NEAIClassPhaseType = .IDLE
    private var gifIsRunning = false
}

// MARK: - NEAIClassificationViewControllerDelegate
extension NEAIClassificationPresenter: NEAIClassificationDelegate {

    func load() {
        demo = .neaiClassification
        
        demoFeatures = param.node.characteristics.features(with: Demo.neaiClassification.features)
        
        view.configureView()
    }
    
    func enableNotification() {
        if let feature = param.node.characteristics.allFeatures().first(where: {feature in feature is NEAIClassificationFeature}) {
            BlueManager.shared.enableNotifications(for: param.node, feature: feature)
        }
    }
    
    func disableNotification() {
        if let feature = param.node.characteristics.allFeatures().first(where: {feature in feature is NEAIClassificationFeature}) {
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
    
    func startClassification() {
        if (generalPhaseStatus != .BUSY) {
            sendNEAICommand(NEAIClassificationCommand.start)
            self.view.view.makeToast(Localizer.NeaiClassification.Text.startClassificationMessage.localized, duration: 1.0)
        } else {
            askIfForceStartCommand()
        }
    }
    
    func stopClassification() {
        sendNEAICommand(NEAIClassificationCommand.stop)
        self.view.view.makeToast(Localizer.NeaiClassification.Text.stopClassificationMessage.localized, duration: 1.0)
    }
    
    func showAllClassesSwitchTapped() {
        print("Show All Classes Switch Tapped")
    }


    func updateNEAIClassificationUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<NEAIClassificationData>,
           let data = sample.data {
            
            let modeValue = data.mode.value
            let phaseValue = data.phase?.value
            let stateValue = data.state?.value
            let classNumberValue = data.classesNumber?.value
            let mostProbableClassValue = data.classMajorProbability?.value
            
            let prob1Value = data.class1Probability?.value
            let prob2Value = data.class2Probability?.value
            let prob3Value = data.class3Probability?.value
            let prob4Value = data.class4Probability?.value
            let prob5Value = data.class5Probability?.value
            let prob6Value = data.class6Probability?.value
            let prob7Value = data.class7Probability?.value
            let prob8Value = data.class8Probability?.value
            
            
            if(modeValue == NEAIClassModeType.ONE_CLASS){
                self.view.outlierSV.isHidden = false
                self.view.neaiClassTitle.text = Localizer.NeaiClassification.Title.oneClass.localized
            } else if (modeValue == NEAIClassModeType.N_CLASS) {
                self.view.outlierSV.isHidden = true
                self.view.neaiClassTitle.text = Localizer.NeaiClassification.Title.nClass.localized
            } else {
                self.view.neaiClassTitle.text = Localizer.NeaiClassification.Title.wrongClass.localized
            }
            
            if let phase = phaseValue {
                if phase == NEAIClassPhaseType.NULL {
                    self.view.phaseValue.text = Localizer.NeaiClassification.Text.noValue.localized
                } else {
                    self.view.phaseValue.text = phase.description
                    self.updateUiBasedOnPhase(phase: phase)
                }
            }
            
            
            if stateValue == NEAIClassStateType.NULL {
                self.view.stateValue.text = Localizer.NeaiClassification.Text.noValue.localized
            } else {
                self.view.stateValue.text = stateValue?.description
            }
            
            
            if mostProbableClassValue == 0 {
                self.view.mostProbableClassValue.text = Localizer.NeaiClassification.Text.unknown.localized
            } else {
                self.view.mostProbableClassValue.text = "\(mostProbableClassValue ?? 0)"
            }
            
            if classNumberValue == 1 {
                if prob1Value == 0 {
                    self.view.outlierValue.text = Localizer.NeaiClassification.Outlier.no.localized
                } else {
                    if prob1Value != 0xFF {
                        self.view.outlierValue.text = Localizer.NeaiClassification.Outlier.yes.localized
                    } else {
                        self.view.outlierValue.text = Localizer.NeaiClassification.Text.noValue.localized
                    }
                }
            }
            
            if let prob1Value = prob1Value {
                self.view.prob1SV.isHidden = false
                self.view.probability1Label.text = "CL 1 (\(prob1Value)%): "
                self.view.probability1Progress.setProgress(Float(Float(prob1Value)/100), animated: true)
                if mostProbableClassValue == 1 {
                    self.view.probability1Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability1Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob1SV.isHidden = true
            }
            
            if let prob2Value = prob2Value {
                self.view.prob2SV.isHidden = false
                self.view.probability2Label.text = "CL 2 (\(prob2Value)%): "
                self.view.probability2Progress.setProgress(Float(Float(prob2Value)/100), animated: true)
                if mostProbableClassValue == 2 {
                    self.view.probability2Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability2Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob2SV.isHidden = true
            }
            
            if let prob3Value = prob3Value {
                self.view.prob3SV.isHidden = false
                self.view.probability3Label.text = "CL 3 (\(prob3Value)%): "
                self.view.probability3Progress.setProgress(Float(Float(prob3Value)/100), animated: true)
                if mostProbableClassValue == 3 {
                    self.view.probability3Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability3Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob3SV.isHidden = true
            }
            
            if let prob4Value = prob4Value {
                self.view.prob4SV.isHidden = false
                self.view.probability4Label.text = "CL 4 (\(prob4Value)%): "
                self.view.probability4Progress.setProgress(Float(Float(prob4Value)/100), animated: true)
                if mostProbableClassValue == 4 {
                    self.view.probability4Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability4Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob4SV.isHidden = true
            }
            
            if let prob5Value = prob5Value {
                self.view.prob5SV.isHidden = false
                self.view.probability5Label.text = "CL 5 (\(prob5Value)%): "
                self.view.probability5Progress.setProgress(Float(Float(prob5Value)/100), animated: true)
                if mostProbableClassValue == 5 {
                    self.view.probability5Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability5Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob5SV.isHidden = true
            }
            
            if let prob6Value = prob6Value {
                self.view.prob6SV.isHidden = false
                self.view.probability6Label.text = "CL 6 (\(prob6Value)%): "
                self.view.probability6Progress.setProgress(Float(Float(prob6Value)/100), animated: true)
                if mostProbableClassValue == 6 {
                    self.view.probability6Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability6Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob6SV.isHidden = true
            }
            
            if let prob7Value = prob7Value {
                self.view.prob7SV.isHidden = false
                self.view.probability7Label.text = "CL 7 (\(prob7Value)%): "
                self.view.probability7Progress.setProgress(Float(Float(prob7Value)/100), animated: true)
                if mostProbableClassValue == 7 {
                    self.view.probability7Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability7Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob7SV.isHidden = true
            }
            
            if let prob8Value = prob8Value {
                self.view.prob8SV.isHidden = false
                self.view.probability8Label.text = "CL 8 (\(prob8Value)%): "
                self.view.probability8Progress.setProgress(Float(Float(prob8Value)/100), animated: true)
                if mostProbableClassValue == 8 {
                    self.view.probability8Label.textColor = ColorLayout.red.light
                } else {
                    self.view.probability8Label.textColor = ColorLayout.systemBlack.light
                }
            } else {
                self.view.prob8SV.isHidden = true
            }
            
            
        }
    }
}

extension NEAIClassificationPresenter {
    
    private func sendNEAICommand(_ command: NEAIClassificationCommand) {
        if let neaiClassificationFeature = param.node.characteristics.first(with: NEAIClassificationFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: param.node,
                feature: neaiClassificationFeature
            )
            
            Logger.debug(text: command.description)
        }
    }
    
    private func askIfForceStartCommand() {
        let alert = UIAlertController(title: Localizer.NeaiClassification.Alert.title.localized, message: Localizer.NeaiClassification.Alert.message.localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Localizer.NeaiClassification.Alert.cancelBtnLabel.localized, style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: Localizer.NeaiClassification.Alert.startBtnLabel.localized, style: UIAlertAction.Style.destructive, handler: { _ in
            if self.param.node.characteristics.first(with: NEAIClassificationFeature.self) != nil {
                self.sendNEAICommand(NEAIClassificationCommand.start)
                self.view.view.makeToast(Localizer.NeaiClassification.Text.startClassificationMessage.localized, duration: 1.0)
                alert.dismiss(animated: true)
            }
        }))

        self.view.present(alert, animated: true, completion: nil)
    }
    
    private func updateUiBasedOnPhase(phase: NEAIClassPhaseType){
        generalPhaseStatus = phase
        if (phase == .IDLE) {
            self.view.showAllClassesSV.isHidden = true
            self.view.startBtn.isEnabled = true
            self.view.startBtn.isUserInteractionEnabled = true
            self.view.stopBtn.isEnabled = false
            self.view.stopBtn.isUserInteractionEnabled = false
            hideClassesDetail()
            stopAnimatingLogo()
        } else if (phase == .CLASSIFICATION) {
            self.view.showAllClassesSV.isHidden = false
            self.view.startBtn.isEnabled = false
            self.view.startBtn.isUserInteractionEnabled = false
            self.view.stopBtn.isEnabled = true
            self.view.stopBtn.isUserInteractionEnabled = true
            updateClassesDetail()
            startAnimatingLogo()
        } else if (phase == .BUSY) {
            self.view.showAllClassesSV.isHidden = true
            self.view.startBtn.isEnabled = true
            self.view.startBtn.isUserInteractionEnabled = true
            self.view.stopBtn.isEnabled = false
            self.view.stopBtn.isUserInteractionEnabled = false
            hideClassesDetail()
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
    
    private func updateClassesDetail(){
        if(self.view.showAllClassesSwitch.isOn){
            self.view.probabilitiesSV.isHidden = false
            self.view.mostProbableClassSV.isHidden = true
        } else {
            self.view.probabilitiesSV.isHidden = true
            self.view.mostProbableClassSV.isHidden = false
        }
    }
    
    private func hideClassesDetail(){
        self.view.probabilitiesSV.isHidden = true
        self.view.mostProbableClassSV.isHidden = true
    }
    
}
