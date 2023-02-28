//
//  ExtendedConfigurationViewController+Actions.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import Toast_Swift
import AssetTrackingCloudDashboard

extension ExtendedConfigurationViewController {
    internal func toggleSection(_ section: ECCommandSection) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        
        tableView.reloadData()
    }
    
    internal func sendCommand(_ command: ECCommandType) {
        switch command {
            case .UID, .versionFw, .info, .help, .powerStatus, .clearDB, .DFU, .off, .readCustomCommand:
                feature?.sendCommand(command)
            case .bankStatus:
                feature?.sendCommand(.bankStatus)
            case .bankSwap:
                bankSwap()
            case .setTime:
                feature?.sendCommand(.setTime, string: Date().nowTimeFormattedForBoard)
            case .setDate:
                feature?.sendCommand(.setDate, string: Date().nowDateFormattedForBoard)
            case .changePIN:
                showChangePINAlert()
            case .setWiFi:
                showSetWiFiCredentialsAlert()
            case .setName:
                showSetNameAlert()
            case .readCommand:
                break
            case .readCert:
                setLoadingUIVisible(true)
                feature?.sendCommand(command)
            case .setCert:
                requestCertificate()
            case .readSensorsConfig:
                showSensors()
            case .setSensorsConfig:
                break
        }
        
        if let text = command.executedPhrase {
            view.makeToast(text.localizedFromGUI)
        }
    }
    
    internal func bankSwap() {
        feature?.sendCommand(.bankSwap)
        view.makeToast("The Board will reboot after the disconnection.")
    }
    
    internal func changePin(_ pin: String) {
        feature?.sendCommand(.changePIN, string: pin)
        view.makeToast("The Board will use the new PIN.")
    }
    
    internal func setName(_ name: String) {
        var nameToSend = name
        if(nameToSend.count < 7){
            for _ in 0..<(7 - nameToSend.count) {
                nameToSend = nameToSend + " "
            }
        }
        feature?.sendCommand(.setName, string: nameToSend)
        view.makeToast("The Board will change the name after the disconnection.")
    }
    
    internal func sendWiFiSettings(_ wifisettings: WiFiSettings) {
        feature?.sendCommand(.setWiFi, json: wifisettings)
        view.makeToast("Wi-Fi Credential Sent to Board.")
    }
    
    internal func showChangePINAlert() {
        let limit = 6
        var aTextField: UITextField?
        let confirmButton = UIAlertAction.genericButton("OK".localizedFromGUI) { [weak self] _ in
            if let text = aTextField?.text, !text.isEmpty {
                self?.changePin(text)
            }
        }
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: "ext.command.changepin.alert.title".localizedFromGUI,
                                                message: "",
                                                confirmButton: confirmButton,
                                                cancelButton: UIAlertAction.cancelButton()) { textfield, controller in
            aTextField = textfield
            textfield.keyboardType = .numberPad
            textfield.placeholder = "123456"
            textfield.onKeyPress { [weak controller] text in
                let isValid = text.count <= limit
                defer {
                    if isValid { controller?.message = "\(text.count)/\(limit)" }
                }
                return isValid
            }
        }
    }
    
    internal func showSetNameAlert() {
        let limit = 7
        var aTextField: UITextField?
        let confirmButton = UIAlertAction.genericButton("OK".localizedFromGUI) { [weak self] _ in
            if let text = aTextField?.text, !text.isEmpty {
                self?.setName(text)
            }
        }
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: "ext.command.setname.alert.title".localizedFromGUI,
                                                message: "",
                                                confirmButton: confirmButton,
                                                cancelButton: UIAlertAction.cancelButton()) { [weak self] textfield, controller in
            aTextField = textfield
            textfield.placeholder = self?.node.name
            textfield.onKeyPress { [weak controller] text in
                let isValid = text.count <= limit
                defer {
                    if isValid { controller?.message = "\(text.count)/\(limit)" }
                }
                return isValid
            }
        }
    }
    
    internal func showSetWiFiCredentialsAlert() {
        UpdateWifiSettingsViewController.presentFrom(viewController: self, security: "OPEN") { [weak self] wifisettings in
            self?.sendWiFiSettings(wifisettings)
        }
    }
    
    internal func showSensors() {
        let controller = ExtendedConfigurationSensorsViewController()
        controller.extConfFeature = feature
        present(controller, animated: true, completion: nil)
    }
    
    internal func sendCertificate(_ certificate: String) {
        setLoadingUIVisible(true)
        feature?.sendCommand(.setCert, string: certificate)
        
        dismiss(animated: true, completion: nil)
        
        view.makeToast("Certificated registered")
    }
    
    internal func showCertificate(_ certificate: String?) {
        let controller = DeviceCertificateRequestViewController()
        controller.certificate = certificate
        controller.uid = uid
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    internal func showFlashBankStatus(_ status: BankStatusResponse?) {
        if !(status == nil){
            if #available(iOS 13.0, *) {
                let controller: BankStatusViewController = BankStatusViewController(node: node, flashStatus: status!)
                let navController = UINavigationController(rootViewController: controller)
                present(navController, animated: true, completion: nil)
            } else {
                view.makeToast("Available only for iOS > 13.0")
            }
        }
    }
    
    internal func requestCertificate() {
        /** Create Asset Tracking button */
        let ATRAction = UIAlertAction(title: "Asset Tracking", style: .default) { (action:UIAlertAction!) in
            self.requestATRCertificate()
        }
        
        /** Create Predictive Maintenance button */
        let PREDMNTAction = UIAlertAction(title: "Predictive Maintenance", style: .default) { (action:UIAlertAction!) in
            self.requestPREDMNTCertificate()
        }
        
        let actions: [UIAlertAction] = [ATRAction, PREDMNTAction, UIAlertAction.cancelButton()]
        UIAlertController.presentActionSheet(from: self, title: "Choose Cloud Dashboard", message: nil, actions: actions)
    }
    
    internal func requestATRCertificate(){
        let controller = DeviceCertificateRequestViewController()
        controller.uid = uid
        controller.didReceivedCertificate = { [weak self] certificate in
            self?.sendCertificate(certificate)
        }
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
        
        view.makeToast("Certificated received")
    }
    
    internal func requestPREDMNTCertificate(){
        let cloudVc = AssetTrackingCloudBundle.buildATRLoginViewController(loginManager: CloudConfig.predmntLoginManager)
        cloudVc.delegate = self
        self.present(UINavigationController(rootViewController: cloudVc), animated: true, completion: nil)
    }
}

extension UITextField: UITextFieldDelegate {
    public typealias OnKeyPressCompletion = (String) -> Bool
    
    private struct AssociatedKeys {
        static var OnKeyPressCompletion = "OnKeyPressCompletion"
    }
    
    public func onKeyPress(_ handler: @escaping OnKeyPressCompletion) {
        let wrapper: Atomic<OnKeyPressCompletion> = Atomic(handler)
        
        objc_setAssociatedObject(self, &AssociatedKeys.OnKeyPressCompletion, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        delegate = self
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let completion = objc_getAssociatedObject(self, &AssociatedKeys.OnKeyPressCompletion) as? Atomic<OnKeyPressCompletion> {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return completion.value(updatedText)
        }
        
        return true
    }
}
