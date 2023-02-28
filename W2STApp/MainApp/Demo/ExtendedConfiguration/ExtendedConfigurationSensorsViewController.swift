//
//  ExtendedConfigurationSensorsViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 03/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class ExtendedConfigurationSensorsViewController: HighSpeedDataLogConfigurationViewController {
    private var response: ECResponse?
    
    var extConfFeature: BlueSTSDKFeatureExtendedConfiguration?
    override var sensors: [HSDSensor] {
        response?.sensors ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = currentTheme.color.background
        
        headerView.removeFromSuperview()
        tableView.removeFromSuperview()
        
        view.addSubviewAndFit(tableView)
        
        reloadSectionBasedOnStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        extConfFeature?.add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        extConfFeature?.remove(self)
    }
    
    override func reloadModel() {
        setLoadingUIVisible(true)
        
        extConfFeature?.sendCommand(.readSensorsConfig)
    }
    
    override func sendSetCommand(_ command: HSDSetCmd, _ completion: @escaping () -> Void) {
        extConfFeature?.sendHSDCommand(command) { [weak self] in
            self?.currentMLCSubSensorUFCLoading?.status.ucfLoaded = true
            self?.updateUI()
            
            completion()
        }
    }
    
    override func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        DispatchQueue.main.async {
            if let sample = sample as? ECFeatureSample {
                self.response = sample.response
                self.setLoadingUIVisible(false)
                self.updateUI()
            }
        }
    }
}
