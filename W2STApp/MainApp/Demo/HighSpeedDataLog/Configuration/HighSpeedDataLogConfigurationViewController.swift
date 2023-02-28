//
//  HighSpeedDataLogConfigurationViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 27/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class HighSpeedDataLogConfigurationViewController: HighSpeedDataLogBaseViewController {
    internal let tableView = UITableView()
    internal var sensors: [HSDSensor] {
        model?.sensor ?? []
    }
    internal var expandendIndexes: Set<IndexPath> = []
    internal var documentSelector = DocumentSelector()
    internal var documentSaver = DocumentSaver()
    internal var currentMLCSubSensorUFCLoading: HSDSensorTouple?
    
    override func setupUI() {
        super.setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        view.addSubview(tableView, constraints: [
            equal(\.topAnchor, toView: headerView, withAnchor: \.bottomAnchor, constant: 0),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
    }
    
    override func setLoadingUIVisible(_ visible: Bool, text: String = "") {
        super.setLoadingUIVisible(visible, text: text)
        
        tableView.isHidden = visible
    }
    
    internal func reloadModel() {
        guard !isLogging else { return }
        
        if model == nil {
            expandendIndexes = []
            
            setLoadingUIVisible(true, text: "hsdlog.config.loading.text".localizedFromGUI)
            feature?.sendGetCommand(HSDGetCmd.GetDevice)
        } else {
            setLoadingUIVisible(false)
        }
    }
    
    internal func setIsLoggingUIVisible(_ visible: Bool) {
        if visible {
            setLoadingUIVisible(true, text: "hsdlog.config.islogging.text".localizedFromGUI)
        }
    }
    
    internal func sendSetCommand(_ command: HSDSetCmd, _ completion: @escaping () -> Void) {
        feature?.sendSetCommand(command, completion: completion)
    }
    
    override func updateUI() {
        super.updateUI()
        
        tableView.reloadData()
    }

    override func updateDeviceStatusDependentUI() {
        super.updateDeviceStatusDependentUI()
        
        if  let sensordId = deviceStatus?.sensorId,
            let sensorStatus = deviceStatus?.sensorStatus,
           !sensorStatus.subSensorStatus.isEmpty {
            let sensor = self.model?.sensorWithId(sensordId)
            sensor?.sensorStatus = sensorStatus
            
            updateUI()
        }
    }
    
    override func reloadSectionBasedOnStatus() {
        if tryToSwitchToTagOnStartPerformed && isLogging {
            switchToTag()
        }
        
        reloadModel()
        
        setIsLoggingUIVisible(isLogging)
    }
    
    override func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        super.didUpdate(feature, sample: sample)
    }
}
