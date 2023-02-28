//
//  NEAIAnomalyDetectionViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import BlueSTSDK

class NEAIAnomalyDetectionViewController : BlueMSDemoTabViewController {
    
    @IBOutlet weak var neaiLogo: UIImageView!
    @IBOutlet weak var payloadLabel: UILabel!
    @IBOutlet weak var gearAi: UIImageView!
    
    /** UI data element */
    @IBOutlet weak var phase: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var phaseProgress: UILabel!
    @IBOutlet weak var phaseProgressBar: UIProgressView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var similarity: UILabel!
    @IBOutlet weak var signalStatusImage: UIImageView!
    
    /** UI stackviews */
    @IBOutlet weak var neaiCommandsSV: UIStackView!
    @IBOutlet weak var librarySV: UIStackView!
    
    /** UI NEAI section commands */
    @IBOutlet weak var learningDetectingSwitch: UISwitch!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetKnowledgeButton: UIButton!
    
    private var mNEAIAD: BlueSTSDKFeatureNEAIAnomalyDetection?
    private var featureWasEnabled = false
    private let noData = "---"
    
    private var gifIsRunning = false
    
    private var generalPhaseStatus: BlueSTSDKFeatureNEAIAnomalyDetection.PhaseType = .IDLE
    
    /** Open / Close NEAI Commands menú */
    @IBAction func neaiCommandsMenuTapped(_ sender: Any) {
        let btnImage: UIButton = sender as! UIButton
        if #available(iOS 13.0, *) {
            if(btnImage.currentImage == UIImage(systemName: "chevron.up")){
                btnImage.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                neaiCommandsSV.isHidden = true
            } else {
                btnImage.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                neaiCommandsSV.isHidden = false
            }
        }
    }
    
    /** Open / Close Library menú */
    @IBAction func libraryMenuTapped(_ sender: Any) {
        let btnImage: UIButton = sender as! UIButton
        if #available(iOS 13.0, *) {
            if(btnImage.currentImage == UIImage(systemName: "chevron.up")){
                btnImage.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                librarySV.isHidden = true
            } else {
                btnImage.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                librarySV.isHidden = false
            }
        }
    }
    
    /** Set Learning / Detecting Switch UI */
    @IBAction func learningDetectingSwitchTapped(_ sender: Any) {
        if (generalPhaseStatus == .LEARNING || generalPhaseStatus == .DETECTION) {
            if(learningDetectingSwitch.isOn){
                learningDetectingSwitch.isOn = false
            } else {
                learningDetectingSwitch.isOn = true
            }
        }
    }
    
    /** Handle Start / Stop Button  */
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        guard let mNEAIAD = mNEAIAD else { return }
        if(generalPhaseStatus != .BUSY){
            if(generalPhaseStatus == .LEARNING || generalPhaseStatus == .DETECTION){
                mNEAIAD.writeStopCommand(f: mNEAIAD)
            } else {
                if (learningDetectingSwitch.isOn == false) {
                    mNEAIAD.writeLearningCommand(f: mNEAIAD)
                } else if(learningDetectingSwitch.isOn == true) {
                    mNEAIAD.writeDetectionCommand(f: mNEAIAD)
                }
            }
        } else {
            askIfForceStartCommand()
        }
    }
    
    /** Handle Reset Knowledge Button  */
    @IBAction func resetKnowledgeTappedButton(_ sender: Any) {
        guard let mNEAIAD = mNEAIAD else {
            return
        }
        mNEAIAD.writeResetKnowledgeCommand(f: mNEAIAD)
        view.makeToast("Reset DONE.")
    }
    
    private func startAnimatingLogo() {
        if !(gifIsRunning){
            let neaiGif = UIImage.gifImageWithName("NEAILogoWhite")
            neaiLogo.image = neaiGif
            gifIsRunning = true
        }
    }
    
    private func stopAnimatingLogo() {
        if(gifIsRunning){
            let staticLogo = UIImage(named: "NEAI_logo", in: Bundle(for: NEAIAnomalyDetectionViewController.self), compatibleWith: nil) ?? .none
            neaiLogo.image = staticLogo
            gifIsRunning = false
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
    }

    public override func viewDidLoad() {
        super.viewDidLoad();
        
        ///Rotate 90 degrees the AI Gear
        gearAi.transform = gearAi.transform.rotated(by: .pi / 2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                       name: UIApplication.didEnterBackgroundNotification,
                                                       object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        stopNotification()
    }
    
    public func startNotification(){
        mNEAIAD = self.node.getFeatureOfType(BlueSTSDKFeatureNEAIAnomalyDetection.self) as? BlueSTSDKFeatureNEAIAnomalyDetection
        if let feature = mNEAIAD{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }

    public func stopNotification(){
        if let feature = mNEAIAD{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }


    @objc func didEnterForeground() {
        mNEAIAD = self.node.getFeatureOfType(BlueSTSDKFeatureNEAIAnomalyDetection.self) as? BlueSTSDKFeatureNEAIAnomalyDetection
        if !(mNEAIAD==nil) && node.isEnableNotification(mNEAIAD!) {
            featureWasEnabled = true
            stopNotification()
        }else {
            featureWasEnabled = false;
        }
    }
        
    @objc func didBecomeActivity() {
        if(featureWasEnabled) {
            startNotification()
        }
    }
    
    private func askIfForceStartCommand() {
        let alert = UIAlertController(title: "WARNING!", message: "Resources are busy with another process. Do you want to stop it and start NEAI-Anomaly Detection anyway?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "START", style: UIAlertAction.Style.destructive, handler: { _ in
            if(self.learningDetectingSwitch.isOn){
                if let feature = self.mNEAIAD { feature.writeDetectionCommand(f: feature) }
                self.showToast(message: "Start Detection", seconds: 1.0)
            } else {
                if let feature = self.mNEAIAD { feature.writeLearningCommand(f: feature) }
                self.showToast(message: "Start Learning", seconds: 1.0)
            }
            alert.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}


extension NEAIAnomalyDetectionViewController : BlueSTSDKFeatureDelegate{
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        mNEAIAD = self.node.getFeatureOfType(BlueSTSDKFeatureNEAIAnomalyDetection.self) as? BlueSTSDKFeatureNEAIAnomalyDetection
        
        if let feature = mNEAIAD{
            let phaseValue = feature.getPhaseValue(sample: sample)
            let stateValue = feature.getStateValue(sample: sample)
            let phaseProgressValue = feature.getPhaseProgressValue(sample: sample)
            let statusValue = feature.getStatusValue(sample: sample)
            let similarityValue = feature.getSimilarityValue(sample: sample)
            
            DispatchQueue.main.async {
                self.payloadLabel.text = "DEBUG RAW DATA\npayload --> phase:\(phaseValue.rawValue) - state:\(stateValue.rawValue) - phase_progress:\(phaseProgressValue) - status:\(statusValue.rawValue) -similarity:\(similarityValue)"
                
                self.setPhaseUI(with: phaseValue)
                self.setStateUI(with: stateValue)
                self.setPhaseProgressUI(with: phaseProgressValue)
                self.setStatusUI(with: statusValue)
                self.setSimilarityUI(with: similarityValue)
            }
        }
        
    }
    
    private func setPhaseUI(with phaseValue: BlueSTSDKFeatureNEAIAnomalyDetection.PhaseType){
        guard phaseValue != BlueSTSDKFeatureNEAIAnomalyDetection.PhaseType.NULL else {
            self.phase.text = noData
            return
        }
        var textToDisplay = "\(phaseValue)"
        textToDisplay = textToDisplay.replacingOccurrences(of: "_", with: " ")
        self.phase.text = textToDisplay
        self.updateUiBasedOnPhase(phase: phaseValue)
    }
    
    private func setStateUI(with stateValue: BlueSTSDKFeatureNEAIAnomalyDetection.StateType){
        guard stateValue != BlueSTSDKFeatureNEAIAnomalyDetection.StateType.NULL else {
            self.state.text = noData
            return
        }
        var textToDisplay = "\(stateValue)"
        textToDisplay = textToDisplay.replacingOccurrences(of: "_", with: " ")
        self.state.text = textToDisplay
    }
    
    private func setPhaseProgressUI(with phaseProgressValue: Int){
        self.phaseProgressBar.progressTintColor = .blue
        guard phaseProgressValue != 255 else {
            self.phaseProgress.text = noData
            self.phaseProgressBar.isHidden = true
            return
        }
        self.phaseProgress.text = "\(phaseProgressValue)%"
        self.phaseProgressBar.isHidden = false
        DispatchQueue.main.async {
            self.phaseProgressBar.setProgress(Float(Float(phaseProgressValue)/100), animated: true)
        }
    }
    
    private func setStatusUI(with statusValue: BlueSTSDKFeatureNEAIAnomalyDetection.StatusType){
        guard statusValue != BlueSTSDKFeatureNEAIAnomalyDetection.StatusType.NULL else {
            self.status.text = noData
            return
        }
        if(statusValue == BlueSTSDKFeatureNEAIAnomalyDetection.StatusType.ANOMALY){
            signalStatusImage.image = UIImage(named: "predictive_warning", in: Bundle(for: NEAIAnomalyDetectionViewController.self), compatibleWith: nil) ?? .none
        } else {
            signalStatusImage.image = UIImage(named: "predictive_good", in: Bundle(for: NEAIAnomalyDetectionViewController.self), compatibleWith: nil) ?? .none
        }
        self.status.text = "\(statusValue)"
    }
    
    private func setSimilarityUI(with similarityValue: Int){
        guard similarityValue != 255 else {
            self.similarity.text = noData
            return
        }
        self.similarity.text = "\(similarityValue)%"
    }
    
    private func updateUiBasedOnPhase(phase: BlueSTSDKFeatureNEAIAnomalyDetection.PhaseType){
        generalPhaseStatus = phase
        
        if (phase == .IDLE) {
            stopAnimatingLogo()
            startStopButton.setTitle("Start", for: .normal)
            resetKnowledgeButton.isEnabled = false
            resetKnowledgeButton.isUserInteractionEnabled = false
            learningDetectingSwitch.isOn = false
            learningDetectingSwitch.isEnabled = true
            learningDetectingSwitch.isUserInteractionEnabled = true
            //signalStatusImage.isHidden = true
            signalStatusImage.image = .none
            phaseProgressBar.setProgress(Float(0), animated: true)
            phaseProgressBar.isHidden = true
        } else if (phase == .IDLE_TRAINED) {
            stopAnimatingLogo()
            startStopButton.setTitle("Start", for: .normal)
            resetKnowledgeButton.isEnabled = true
            resetKnowledgeButton.isUserInteractionEnabled = true
            learningDetectingSwitch.isOn = false
            learningDetectingSwitch.isEnabled = true
            learningDetectingSwitch.isUserInteractionEnabled = true
            learningDetectingSwitch.isOn = true
            signalStatusImage.image = .none
            phaseProgressBar.setProgress(Float(0), animated: true)
            phaseProgressBar.isHidden = true
        } else if(phase == .LEARNING) {
            startAnimatingLogo()
            startStopButton.setTitle("STOP", for: .normal)
            resetKnowledgeButton.isEnabled = false
            resetKnowledgeButton.isUserInteractionEnabled = false
            learningDetectingSwitch.isOn = false
            learningDetectingSwitch.isEnabled = false
            learningDetectingSwitch.isUserInteractionEnabled = false
            //signalStatusImage.isHidden = true
            signalStatusImage.image = .none
            phaseProgressBar.isHidden = false
        } else if(phase == .DETECTION) {
            startAnimatingLogo()
            startStopButton.setTitle("STOP", for: .normal)
            resetKnowledgeButton.isEnabled = false
            resetKnowledgeButton.isUserInteractionEnabled = false
            learningDetectingSwitch.isOn = true
            learningDetectingSwitch.isEnabled = false
            learningDetectingSwitch.isUserInteractionEnabled = false
            //signalStatusImage.isHidden = false
            phaseProgressBar.setProgress(Float(0), animated: true)
            phaseProgressBar.isHidden = true
        } else if(phase == .BUSY) {
            stopAnimatingLogo()
            startStopButton.setTitle("Start", for: .normal)
            resetKnowledgeButton.isEnabled = false
            resetKnowledgeButton.isUserInteractionEnabled = false
            learningDetectingSwitch.isEnabled = true
            learningDetectingSwitch.isUserInteractionEnabled = true
            //signalStatusImage.isHidden = false
            phaseProgressBar.setProgress(Float(0), animated: true)
            phaseProgressBar.isHidden = true
        }
    }
}
