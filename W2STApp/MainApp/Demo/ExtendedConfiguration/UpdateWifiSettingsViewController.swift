//
//  UpdateWifiSettingsViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 29/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit

class UpdateWifiSettingsViewController: UIViewController {
    typealias Completion = (WiFiSettings) -> Void
    
    let ssidField = UITextField()
    let passwordField = UITextField()
    let securityLabel = UILabel()
    let securityButton = UIButton()
    let securityIcon = UIImageView(image: UIImage.namedFromGUI("icon_arrow_fill_down"))
    
    var didChangeSettings: Completion = { _ in }
    
    static func presentFrom(viewController: UIViewController, security: String, completion: @escaping Completion) {
        let controller = UpdateWifiSettingsViewController()
        let navController = UINavigationController(rootViewController: controller)
        controller.didChangeSettings = completion
        controller.setSecurity(security)
        
        viewController.present(navController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "update.wifi.credentials.title".localizedFromGUI
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "update.wifi.credentials.done".localizedFromGUI, style: .done, target: self, action: #selector(save))
        view.backgroundColor = currentTheme.color.background
        
        securityIcon.setDimensionContraints(width: 10, height: nil)
        securityIcon.contentMode = .scaleAspectFit
        let securityStack = UIStackView.getHorizontalStackView(withSpacing: 8, views: [securityLabel, securityButton, securityIcon])
        let verticalStack = UIStackView.getVerticalStackView(withSpacing: 4, views: [ssidField, passwordField, securityStack])
        
        securityLabel.textColor = currentTheme.color.secondaryText
        securityLabel.font = UIFont.systemFont(ofSize: 14)
        securityLabel.text = "generic.security".localizedFromGUI
        ssidField.placeholder = "generic.ssid".localizedFromGUI
        passwordField.placeholder = "generic.password".localizedFromGUI
        passwordField.isSecureTextEntry = true
        ssidField.setDimensionContraints(width: nil, height: 44)
        passwordField.setDimensionContraints(width: nil, height: 44)
        securityButton.addTarget(self, action: #selector(didTapSecurityButton), for: .touchUpInside)
        securityButton.setTitleColor(currentTheme.color.text, for: .normal)
        ssidField.returnKeyType = .next
        passwordField.returnKeyType = .done
        ssidField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(verticalStack, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ssidField.becomeFirstResponder()
    }
    
    func setSecurity(_ security: String) {
        securityButton.setTitle(security.uppercased(), for: .normal)
    }
    
    @objc
    private func didTapSecurityButton() {
        let actions: [UIAlertAction] = WiFiSettings.WiFiSecurity.allCases.map { item in
            UIAlertAction.genericButton(item.rawValue) { [weak self] _ in
                self?.setSecurity(item.rawValue)
            }
        }
        UIAlertController.presentActionSheet(from: self, title: nil, message: nil, actions: actions)
    }
    
    @objc
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func save() {
        if let ssid = ssidField.text,
           let password = passwordField.text,
           let security = securityButton.titleLabel?.text,
           !security.isEmpty, !ssid.isEmpty, !password.isEmpty {
            didChangeSettings(WiFiSettings(enable: true, ssid: ssid, password: password, securityType: security))
            
            dismissController()
        }
    }
}

extension UpdateWifiSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ssidField {
            passwordField.becomeFirstResponder()
        } else {
            passwordField.resignFirstResponder()
        }
        
        return false
    }
}
