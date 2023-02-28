//
//  HighSpeedDataLogConfigurationViewController+SaveConfig.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

extension HighSpeedDataLogConfigurationViewController {
    internal func showSaveConfigChooser() {
        UIAlertController.presentActionSheet(from: self, title: "hsd_saveconf_title".localizedFromGUI, actions: [
            UIAlertAction(title: "hsd_saveconf_save_locally".localizedFromGUI, style: .default, handler: { [weak self] _ in
                self?.saveConfigurationLocally()
            }),
            UIAlertAction(title: "hsd_saveconf_asDefault".localizedFromGUI, style: .default, handler: { [weak self] _ in
                self?.setCurrentConfigurationAsDefault()
            }),
            UIAlertAction(title: "hsd_saveconf_all".localizedFromGUI, style: .default, handler: { [weak self] _ in
                self?.setCurrentConfigurationAsDefault()
                self?.saveConfigurationLocally()
            }),
            UIAlertAction.cancelButton()
        ])
    }
    
    internal func setCurrentConfigurationAsDefault() {
        feature?.sendControlCommand(HSDCmd.Save)
    }
    
    internal func saveConfigurationLocally() {
        getFileName { [weak self] name in
            self?.exportConfigurationWithFilename(name)
        }
    }
    
    internal func exportConfigurationWithFilename(_ filename: String) {
        guard let sensors = model?.sensor,
              let data = try? JSONEncoder().encode(sensors) else { return }
        
        let tempURL = FileManager().temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: tempURL)
            documentSaver.saveFile(atURL: tempURL, from: self) { _ in }
            
        } catch {
            debugPrint("ERROR Writing file: \(error)")
        }
    }
    
    internal func getFileName(completion: @escaping (String) -> Void) {
        var aTextField: UITextField?
        
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: "hsd_filename_alert".localizedFromGUI,
                                                message: nil,
                                                confirmButton: UIAlertAction(title: "hsd_filename_alert_done".localizedFromGUI, style: .default, handler: { _ in
                                                    if let text = aTextField?.text, !text.isEmpty {
                                                        completion(text)
                                                    }
                                                }),
                                                cancelButton: UIAlertAction.cancelButton()) { textField, _ in
            textField.text = "hsd_filename_default".localizedFromGUI
            aTextField = textField
        }
    }
}
