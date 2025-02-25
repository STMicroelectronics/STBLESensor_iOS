//
//  MotorControlViewController.swift
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

final class MotorControlViewController: DemoNodeNoViewController<MotorControlDelegate> {

    weak var motorDelegate: MotorControlIsRunningDelegate?
    
    var containerMotorInformationView = UIView()
    let motorInformationView = MotorInformationView()
    
    var containerSlowTelemetriesView = UIView()
    let slowTelemetriesView = SlowMotorTelemetriesView()
    
    var motorFault: MotorControlFault = MotorControlFault.none
    var motorIsRunning = false
    var motorSpeed = 0
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.sendGetStatusMotorControllerCommand()
        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        containerMotorInformationView = motorInformationView.embedInView(with: .standard)
        containerSlowTelemetriesView = slowTelemetriesView.embedInView(with: .standard)
        
        motorInformationView.motorSpeedSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        motorInformationView.motorSpeedSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        
        self.setMotorStatus(motorIsRunning: self.motorIsRunning)
        self.setMotorSpeed(motorSpeed: self.motorSpeed)
        
        motorInformationView.motorButton.onTap { _ in
            if self.motorFault != .none {
                self.presenter.sendMotorAckFault()
                self.resetViewAfterFault()
            } else {
                if self.motorIsRunning {
                    self.presenter.sendStopMotorCommand()
                    self.presenter.sendGetStatusMotorControllerCommand()
                    self.setMotorStatus(motorIsRunning: false)
                } else {
                    self.presenter.sendStartMotorCommand()
                    self.presenter.sendGetStatusMotorControllerCommand()
                    self.setMotorStatus(motorIsRunning: true)
                    self.setMotorSpeed(motorSpeed: self.motorSpeed)
                }
            }
        }
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            containerMotorInformationView, 
            containerSlowTelemetriesView
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerMotorInformationView.backgroundColor = .white
        containerMotorInformationView.layer.cornerRadius = 8.0
        containerMotorInformationView.applyShadow()
        
        containerSlowTelemetriesView.backgroundColor = .white
        containerSlowTelemetriesView.layer.cornerRadius = 8.0
        containerSlowTelemetriesView.applyShadow()
    }
    
    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        if feature is PnPLFeature {
            presenter.newPnPLSample(with: sample, and: feature)
        } else if feature is RawPnPLControlledFeature {
            presenter.newRawPnPLControlledSample(with: sample, and: feature)
        }
    }
    
    func setMotorStatus(motorIsRunning: Bool) {
        self.motorIsRunning = motorIsRunning
        motorDelegate?.isMotorRunning(isRunning: self.motorIsRunning)
        
        if motorIsRunning{
            motorInformationView.motorStatusImage.image = ImageLayout.image(with: "motor_info_running", in: .module)
            
            motorInformationView.motorStatusLabel.text = "RUNNING"
            motorInformationView.motorStatusLabel.textColor = ColorLayout.greenDark.auto
            
            motorInformationView.motorSpeedStackView.isHidden = false
            
            motorInformationView.motorButton.setTitle("STOP", for: .normal)
            Buttonlayout.standardRed.apply(to: motorInformationView.motorButton)
            
            slowTelemetriesView.userDescription.text = "To stop acquisition you must stop before the motor via the 'STOP' button and stop the acquisition with the STOP button"
        } else {
            motorInformationView.motorStatusImage.image = ImageLayout.image(with: "motor_info_stopped", in: .module)
            
            motorInformationView.motorStatusLabel.text = "STOPPED"
            motorInformationView.motorStatusLabel.textColor = ColorLayout.redDark.auto
            
            motorInformationView.motorSpeedStackView.isHidden = true
            
            motorInformationView.motorButton.setTitle("START", for: .normal)
            Buttonlayout.standardGreen.apply(to: motorInformationView.motorButton)
            
            slowTelemetriesView.userDescription.text = "To view the data given by the motor, you must start the acquisition via the PLAY button and enable the motor via the START button"
        }
    }
    
    func setMotorSpeed(motorSpeed: Int) {
        self.motorSpeed = motorSpeed
        motorInformationView.motorSpeedSlider.setValue(Float(motorSpeed), animated: true)
        motorInformationView.motorSpeedLabel.text = "Motor Speed: \(motorSpeed)"
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        motorInformationView.motorSpeedSlider.setValue(Float(sender.value), animated: true)
        self.motorSpeed = Int(sender.value)
        motorInformationView.motorSpeedLabel.text = "Motor Speed: \(motorSpeed)"
    }

    @objc func sliderTouchEnded(_ sender: UISlider) {
        self.presenter.sendMotorSpeedValue(speed: Int(sender.value))
        self.presenter.sendGetStatusMotorControllerCommand()
    }
    
    func resetViewAfterFault() {
        self.motorFault = .none
        TextLayout.info.apply(to: motorInformationView.motorStatusMessage)
        motorInformationView.motorStatusMessage.text = "No fault message"
        self.presenter.sendGetStatusMotorControllerCommand()
        
    }
}
