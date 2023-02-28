//
//  HighSpeedDataLogConfigurationViewController+Actions.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

extension HighSpeedDataLogConfigurationViewController {
    internal func setSensorEnabled(_ enabled: Bool, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        debugPrint("Enabled changed: \(enabled), \(subSensor)")
        let command = HSDSetSensorCmd(sensorId: sensor.id, subSensorStatus: [IsActiveParam(id: subSensor.descriptor.id, isActive: enabled)])
        sendSetCommand(command) {}
        subSensor.status.isActive = enabled
        
        updateUI()
    }
    
    internal func setSensorFS(_ fs: Double, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        debugPrint("FS changed: \(fs), \(subSensor)")
        let command = HSDSetSensorCmd(sensorId: sensor.id, subSensorStatus: [FSParam(id: subSensor.descriptor.id, fs: fs)])
        sendSetCommand(command) {}
        subSensor.status.FS = fs
        
        updateUI()
    }
    
    internal func setSensorODR(_ odr: Double, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        debugPrint("ODR changed: \(odr), \(subSensor)")
        let command = HSDSetSensorCmd(sensorId: sensor.id, subSensorStatus: [ODRParam(id: subSensor.descriptor.id, odr: odr)])
        sendSetCommand(command) {}
        subSensor.status.ODR = odr
        
        updateUI()
    }
    
    internal func setSensorSamplesPerTs(_ samplesPerTs: Int, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        debugPrint("SamplesPerTs changed: \(samplesPerTs), \(subSensor)")
        let command = HSDSetSensorCmd(sensorId: sensor.id, subSensorStatus: [SamplePerTSParam(id: subSensor.descriptor.id, samplesPerTs: samplesPerTs)])
        sendSetCommand(command) {}
        subSensor.status.samplesPerTs = samplesPerTs
        
        updateUI()
    }
    
    internal func setOptionModel(_ optionModel: HSDOptionModel, value: Double, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        switch optionModel.mode {
            case .odr:
                setSensorODR(value, sensor: sensor, subSensor: subSensor)
                
            case .fs:
                setSensorFS(value, sensor: sensor, subSensor: subSensor)
        }
    }
    
    internal func chooseMLCDocument(sensor: HSDSensor, subSensor: HSDSensorTouple) {
        documentSelector.selectFile(from: self) { [weak self, weak sensor] url in
            guard let self = self, let sensor = sensor else { return }
            self.setLoadingUIVisible(true, text: "ucf.loading.text".localizedFromGUI)
            DispatchQueue.main.async {
                if let value = try? String(contentsOf: url) {
                    self.setMLCContent(value, sensor: sensor, subSensor: subSensor)
                } else {
                    self.setLoadingUIVisible(false)
                }
            }
        }
    }
    
    internal func setMLCContent(_ file: String, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        currentMLCSubSensorUFCLoading = subSensor
        let command = HSDSetMLCSensorCmd(sensorId: sensor.id, subSensorStatus: [MLCConfigParam.fromUCFString(id: subSensor.descriptor.id, ucfContent: file)])
        sendSetCommand(command) { [weak self] in
            self?.setLoadingUIVisible(false)
            self?.currentMLCSubSensorUFCLoading = nil
        }
    }
    
    internal func chooseConfigJSON() {
        documentSelector.selectFile(from: self) { [weak self] url in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let value = try? Data(contentsOf: url) {
                    self.applyTryToApplyConfiguration(value)
                }
            }
        }
    }
    
    internal func saveConfig() {
        showSaveConfigChooser()
    }
    
    internal func changeAlias() {
        var aTextField: UITextField?
        
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: "usd_board_alias".localizedFromGUI,
                                                message: nil,
                                                confirmButton: UIAlertAction(title: "generic.save".localizedFromGUI, style: .default, handler: { [weak self] _ in
                                                    if let text = aTextField?.text, !text.isEmpty {
                                                        self?.changeBoardAliasTo(text)
                                                    }
                                                }),
                                                cancelButton: UIAlertAction.cancelButton()) { textField, _ in
            textField.placeholder = "usd_board_alias_placeholder".localizedFromGUI
            aTextField = textField
        }
    }
    
    internal func changeBoardAliasTo(_ text: String) {
        feature?.sendSetCommand(HSDSetDeviceAliasCmd(alias: text)) { [weak self] in self?.reloadModel() }
    }
}

