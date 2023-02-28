//
//  NEAIClassificationViewController.swift
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

class NEAIClassificationViewController : BlueMSDemoTabViewController {
    
    @IBOutlet weak var neaiLogo: UIImageView!
    @IBOutlet weak var payloadLabel: UILabel!
    @IBOutlet weak var gearAi: UIImageView!
    
    /** UI data element */
    @IBOutlet weak var neaiTitle: UILabel!
    @IBOutlet weak var phase: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var outlier: UILabel!
    @IBOutlet weak var mostProbableClass: UILabel!
    @IBOutlet weak var showClassesSwitch: UISwitch!
    
    /** UI stackviews */
    @IBOutlet weak var neaiCommandsSV: UIStackView!
    @IBOutlet weak var neaiOutlierSV: UIStackView!
    @IBOutlet weak var neaiShowAllClassesSV: UIStackView!
    @IBOutlet weak var neaiMostProbableClassSV: UIStackView!
    @IBOutlet weak var neaiClassProbabilitySV: UIStackView!
    
    /** UI NEAI section commands */
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    /** UI Progress Bar stackview collection */
    @IBOutlet weak var probabilitySV1: UIStackView!
    @IBOutlet weak var probabilitySV2: UIStackView!
    @IBOutlet weak var probabilitySV3: UIStackView!
    @IBOutlet weak var probabilitySV4: UIStackView!
    @IBOutlet weak var probabilitySV5: UIStackView!
    @IBOutlet weak var probabilitySV6: UIStackView!
    @IBOutlet weak var probabilitySV7: UIStackView!
    @IBOutlet weak var probabilitySV8: UIStackView!
    
    /** UI Progress Bar collection */
    @IBOutlet weak var probabilityPB1: UIProgressView!
    @IBOutlet weak var probabilityPB2: UIProgressView!
    @IBOutlet weak var probabilityPB3: UIProgressView!
    @IBOutlet weak var probabilityPB4: UIProgressView!
    @IBOutlet weak var probabilityPB5: UIProgressView!
    @IBOutlet weak var probabilityPB6: UIProgressView!
    @IBOutlet weak var probabilityPB7: UIProgressView!
    @IBOutlet weak var probabilityPB8: UIProgressView!
    
    /** UI TextViews collection */
    @IBOutlet weak var probabilityTV1: UILabel!
    @IBOutlet weak var probabilityTV2: UILabel!
    @IBOutlet weak var probabilityTV3: UILabel!
    @IBOutlet weak var probabilityTV4: UILabel!
    @IBOutlet weak var probabilityTV5: UILabel!
    @IBOutlet weak var probabilityTV6: UILabel!
    @IBOutlet weak var probabilityTV7: UILabel!
    @IBOutlet weak var probabilityTV8: UILabel!
    
    private var probabilitiesStackView: [UIStackView] = []
    private var probabilitiesProgressView: [UIProgressView] = []
    private var probabilitiesLabels: [UILabel] = []
    
    private var mNEAIClass: BlueSTSDKFeatureNEAIClassification?
    private var featureWasEnabled = false
    private let noData = "---"
    
    private var gifIsRunning = false
    
    private var generalPhaseStatus: BlueSTSDKFeatureNEAIClassification.PhaseType = .IDLE
    
    @IBAction func onShowClassesSwitchTapped(_ sender: UISwitch) {
        updateClassesDetail()
    }
    
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
    
    /** Handle Start Button  */
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard let mNEAIClass = mNEAIClass else { return }
        if(generalPhaseStatus != BlueSTSDKFeatureNEAIClassification.PhaseType.BUSY){
            mNEAIClass.writeStartClassificationCommand(f: mNEAIClass)
            showToast(message: "Start Classification", seconds: 1.0)
        } else {
            askIfForceStartCommand()
        }
    }
    
    /** Handle Stop Button  */
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        guard let mNEAIClass = mNEAIClass else { return }
        mNEAIClass.writeStopClassificationCommand(f: mNEAIClass)
        showToast(message: "Stop Classification", seconds: 1.0)
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
        setupProbabilitesStackView()
        setupProbabilitesProgressView()
        setupProbabilitesLabels()
        hideProbabilitiesSV()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        stopNotification()
    }
    
    public func startNotification(){
        mNEAIClass = self.node.getFeatureOfType(BlueSTSDKFeatureNEAIClassification.self) as? BlueSTSDKFeatureNEAIClassification
        if let feature = mNEAIClass{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }

    public func stopNotification(){
        if let feature = mNEAIClass{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }

    @objc func didEnterForeground() {
        mNEAIClass = self.node.getFeatureOfType(BlueSTSDKFeatureNEAIClassification.self) as? BlueSTSDKFeatureNEAIClassification
        if !(mNEAIClass==nil) && node.isEnableNotification(mNEAIClass!) {
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

    private func setupProbabilitesStackView(){
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
        probabilitiesStackView.append(probabilitySV1)
    }
    
    private func setupProbabilitesProgressView(){
        probabilitiesProgressView.append(probabilityPB1)
        probabilitiesProgressView.append(probabilityPB2)
        probabilitiesProgressView.append(probabilityPB3)
        probabilitiesProgressView.append(probabilityPB4)
        probabilitiesProgressView.append(probabilityPB5)
        probabilitiesProgressView.append(probabilityPB6)
        probabilitiesProgressView.append(probabilityPB7)
        probabilitiesProgressView.append(probabilityPB8)
    }
    
    private func setupProbabilitesLabels(){
        probabilitiesLabels.append(probabilityTV1)
        probabilitiesLabels.append(probabilityTV2)
        probabilitiesLabels.append(probabilityTV3)
        probabilitiesLabels.append(probabilityTV4)
        probabilitiesLabels.append(probabilityTV5)
        probabilitiesLabels.append(probabilityTV6)
        probabilitiesLabels.append(probabilityTV7)
        probabilitiesLabels.append(probabilityTV8)
    }
    
    private func hideProbabilitiesSV(){
        probabilitiesStackView.forEach{ sv in
            sv.isHidden = true
        }
        probabilitiesProgressView.forEach{ pv in
            pv.isHidden = true
        }
        probabilitiesLabels.forEach{ tv in
            tv.isHidden = true
        }
    }
    
    private func askIfForceStartCommand() {
        let alert = UIAlertController(title: "WARNING!", message: "Resources are busy with another process. Do you want to stop it and start NEAI-Classification anyway?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "START", style: UIAlertAction.Style.destructive, handler: { _ in
            if let feature = self.mNEAIClass{
                feature.writeStartClassificationCommand(f: feature)
                self.showToast(message: "Start Classification", seconds: 1.0)
            }
            alert.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension NEAIClassificationViewController : BlueSTSDKFeatureDelegate{
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        mNEAIClass = self.node.getFeatureOfType(BlueSTSDKFeatureNEAIClassification.self) as? BlueSTSDKFeatureNEAIClassification
        
        if let feature = mNEAIClass{
            let modeValue = feature.getModeValue(sample: sample)
            let phaseValue = feature.getPhaseValue(sample: sample)
            let stateValue = feature.getStateValue(sample: sample)
            let classNumber = feature.getClassNumber(sample: sample)
            let mostProbableClassValue = feature.getMostProbableClass(sample: sample)
            
            var classProbabilities: [Int] = []
            for index in 0..<classNumber {
                classProbabilities.append(feature.getClassProbability(sample: sample, num: index))
            }
            
            DispatchQueue.main.async {
                //self.payloadLabel.text = "DEBUG RAW DATA\npayload --> mode:\(modeValue.rawValue) - most_probable_class:\(mostProbableClassValue) - classNumber:\(classNumber)"
                self.setModeUI(with: modeValue)
                self.setPhaseUI(with: phaseValue)
                self.setStateUI(with: stateValue)
                self.setMostProbableClass(with: mostProbableClassValue)
                self.setOneClassOutlier(with: classProbabilities)
                self.setClassProbabilities(with: classProbabilities, and: mostProbableClassValue)
            }
        }
    }
    
    private func setModeUI(with modeValue: BlueSTSDKFeatureNEAIClassification.ModeType){
        guard modeValue != BlueSTSDKFeatureNEAIClassification.ModeType.NULL else {
            self.neaiOutlierSV.isHidden = true
            return
        }
        if(modeValue == BlueSTSDKFeatureNEAIClassification.ModeType.ONE_CLASS){
            self.neaiOutlierSV.isHidden = false
            neaiTitle.text = "1-Class"
        } else if (modeValue == BlueSTSDKFeatureNEAIClassification.ModeType.N_CLASS) {
            self.neaiOutlierSV.isHidden = true
            neaiTitle.text = "N-Class"
        } else {
            neaiTitle.text = "Something Wrong"
        }
    }
    
    private func setPhaseUI(with phaseValue: BlueSTSDKFeatureNEAIClassification.PhaseType){
        guard phaseValue != BlueSTSDKFeatureNEAIClassification.PhaseType.NULL else {
            self.phase.text = noData
            return
        }
        var textToDisplay = "\(phaseValue)"
        textToDisplay = textToDisplay.replacingOccurrences(of: "_", with: " ")
        self.phase.text = textToDisplay
        self.updateUiBasedOnPhase(phase: phaseValue)
    }
    
    private func setStateUI(with stateValue: BlueSTSDKFeatureNEAIClassification.StateType){
        guard stateValue != BlueSTSDKFeatureNEAIClassification.StateType.NULL else {
            self.state.text = noData
            return
        }
        var textToDisplay = "\(stateValue)"
        textToDisplay = textToDisplay.replacingOccurrences(of: "_", with: " ")
        self.state.text = textToDisplay
    }
    
    private func setMostProbableClass(with mostProbableClass: Int){
        if(mostProbableClass != 0){
            self.mostProbableClass.text = "\(mostProbableClass)"
        } else {
            self.mostProbableClass.text = "Unknown"
        }
    }
    
    private func setClassProbabilities(with classProb: [Int], and mostProbableClass: Int){
        classProb.indices.forEach { element in
            if(classProb[element] != BlueSTSDKFeatureNEAIClassification.CLASS_PROB_ESCAPE_CODE){
                probabilitiesStackView[element].isHidden = false
                probabilitiesLabels[element].isHidden = false
                probabilitiesProgressView[element].isHidden = false
                let string = "CL \(element + 1) (\(classProb[element]) %):"
                probabilitiesLabels[element].text = string
                if(element == (mostProbableClass - 1)){
                    probabilitiesLabels[element].textColor = .red
                } else {
                    probabilitiesLabels[element].textColor = .black
                }
                probabilitiesProgressView[element].setProgress(Float(Float(classProb[element])/100), animated: true)
            } else {
                probabilitiesStackView[element].isHidden = true
            }
        }
    }
        
    private func setOneClassOutlier(with classProbabilities: [Int]) {
        if(classProbabilities.count == 1){
            if(classProbabilities[0] == 0){
                self.outlier.text = "No"
            } else {
                if(classProbabilities[0] != BlueSTSDKFeatureNEAIClassification.CLASS_PROB_ESCAPE_CODE){
                    self.outlier.text = "Yes"
                } else {
                    self.outlier.text = "---"
                }
            }
        }
    }
    
    private func updateUiBasedOnPhase(phase: BlueSTSDKFeatureNEAIClassification.PhaseType){
        generalPhaseStatus = phase
        if (phase == .IDLE) {
            neaiShowAllClassesSV.isHidden = true
            startButton.isEnabled = true
            startButton.isUserInteractionEnabled = true
            stopButton.isEnabled = false
            stopButton.isUserInteractionEnabled = false
            hideClassesDetail()
            stopAnimatingLogo()
        } else if (phase == .CLASSIFICATION) {
            neaiShowAllClassesSV.isHidden = false
            startButton.isEnabled = false
            startButton.isUserInteractionEnabled = false
            stopButton.isEnabled = true
            stopButton.isUserInteractionEnabled = true
            updateClassesDetail()
            startAnimatingLogo()
        } else if (phase == .BUSY) {
            neaiShowAllClassesSV.isHidden = true
            startButton.isEnabled = true
            startButton.isUserInteractionEnabled = true
            stopButton.isEnabled = false
            stopButton.isUserInteractionEnabled = false
            hideClassesDetail()
            stopAnimatingLogo()
        }
    }
    
    private func updateClassesDetail(){
        if(showClassesSwitch.isOn){
            neaiClassProbabilitySV.isHidden = false
            neaiMostProbableClassSV.isHidden = true
        } else {
            neaiClassProbabilitySV.isHidden = true
            neaiMostProbableClassSV.isHidden = false
        }
    }
    
    private func hideClassesDetail(){
        neaiClassProbabilitySV.isHidden = true
        neaiMostProbableClassSV.isHidden = true
    }
}
