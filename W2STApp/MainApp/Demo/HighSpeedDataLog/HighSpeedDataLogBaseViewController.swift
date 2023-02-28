//
//  HighSpeedDataLogBaseViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 29/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class HighSpeedDataLogBaseViewController: BlueMSDemoTabViewController {
    internal let headerView = HighSpeedDataLogHeaderView()
    internal let loadingView = LoadingView()
    internal var didChangeLoadingState: (Bool) -> Void = { _ in }
    internal var isLogging: Bool = false
    internal var model: HSDDevice? {
        feature?.device
    }
    internal var deviceStatus: HSDDeviceStatus? {
        feature?.deviceStatus
    }
    internal var feature: BlueSTSDKFeatureHighSpeedDataLog? {
        node.getFeatureOfType(BlueSTSDKFeatureHighSpeedDataLog.self) as? BlueSTSDKFeatureHighSpeedDataLog
    }
    internal var tryToSwitchToTagOnStartPerformed: Bool {
        (parent as? HighSpeedDataLogViewController)?.tryToSwitchToTagOnStartPerformed ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        enableNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableNotifications()
    }
    
    func setupUI() {
        view.addSubviewAndCenter(loadingView)
        
        view.addSubview(headerView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ])
    }
    
    func setLoadingUIVisible(_ visible: Bool, text: String = "") {
        headerView.isHidden = visible
        loadingView.setVisible(true, text: text)
        
        didChangeLoadingState(visible)
    }
    
    func updateUI() {
        updateHeaderView()
    }
    
    internal func enableNotifications() {
        feature?.addLoggerDelegate(self)
        feature?.add(self)
        feature?.enableNotification()
        feature?.sendGetCommand(HSDGetCmd.LogStatus)
    }
    
    internal func disableNotifications() {
        feature?.removeLoggerDelegate(self)
        feature?.remove(self)
        feature?.disableNotification()
    }
    
    internal func updateDeviceStatusDependentUI() {
        updateHeaderView()
    }
    
    internal func reloadSectionBasedOnStatus() {}
    
    internal func switchToConfig() {
        (parent as? HighSpeedDataLogViewController)?.switchToConfig()
    }
    
    internal func switchToTag() {
        (parent as? HighSpeedDataLogViewController)?.switchToTag()
    }
    
    private func updateHeaderView() {
        headerView.titleLabel.text = model?.deviceInfo.alias
        headerView.subtitleLabel.text = model?.deviceInfo.serialNumber
        
        headerView.battery.icon.image = ColorUtils.getBatteryColored(percentage: deviceStatus?.batteryLevel ?? 0)
        headerView.battery.label.text = "battery.charged".localizedFromGUI
        if let level = deviceStatus?.batteryLevel, level > 0 {
            let batteryLevel = NumberFormatter.localizedString(from: NSNumber(value: level / 100.0), number: .percent)
            headerView.battery.label.text = "\(batteryLevel)"
        }
        
        headerView.cpuUsage.icon.image = UIImage.namedFromGUI("ic_cpu_usage")?.withRenderingMode(.alwaysTemplate)
        
        var cpuLevel = deviceStatus?.cpuUsage ?? 0
        if cpuLevel == 100 { cpuLevel = 0 }
        headerView.cpuUsage.label.text = NumberFormatter.localizedString(from: NSNumber(value: min(cpuLevel/100, 1)), number: .percent)
        headerView.cpuUsage.icon.tintColor = ColorUtils.getColor(percentage: cpuLevel)
    }
    
    private func checkFirmwareVersion() {
        guard let device = model, !device.deviceInfo.firmwareIsUpdated,
              let info = device.deviceInfo.fwErrorInfo else { return }
        
        UIAlertController.presentAlert(from: self,
                                       title: "hsd.firmwareversion.alert.title".localizedFromGUI,
                                       message: "hsd.firmwareversion.alert.message".localizedFromGUI(arguments: [info.currFW, info.targetFW, info.targetFWUrl]),
                                       actions: [UIAlertAction.genericButton()])
    }
}

extension HighSpeedDataLogBaseViewController: BlueSTSDKFeatureLogDelegate {
    func feature(_ feature: BlueSTSDKFeature, rawData raw: Data, sample: BlueSTSDKFeatureSample) {
        //debugPrint("Log Feature: \(feature), rawData: \(raw), sample: \(sample)")
    }
}

extension HighSpeedDataLogBaseViewController: BlueSTSDKFeatureDelegate {
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        //debugPrint("Feature: \(feature), sample: \(sample)")
        
        DispatchQueue.main.async {
            if let sample = sample as? ConfigSample {
                if sample.device != nil {
                    self.setLoadingUIVisible(false)
                    self.checkFirmwareVersion()
                    self.updateUI()
                }
                
                //  When status arrive the board is ready and the sections needs
                //  to be updated based on the status
                if let deviceStatus = sample.deviceStatus {
                    if let logging = deviceStatus.isLogging {
                        self.isLogging = logging
                    }
                    
                    self.updateDeviceStatusDependentUI()
                    self.reloadSectionBasedOnStatus()
                }
            }
        }
    }
}
