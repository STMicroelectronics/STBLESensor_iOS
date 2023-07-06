//
//  UpdateWifiPresenter.swift
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

public class UpdateWifiParam {
    var securityType: WiFiSettings.WiFiSecurity
    var didChangeSettings: (WiFiSettings) -> Void

    init(securityType: WiFiSettings.WiFiSecurity, didChangeSettings: @escaping (WiFiSettings) -> Void) {
        self.securityType = securityType
        self.didChangeSettings = didChangeSettings
    }
}

final class UpdateWifiPresenter: BasePresenter<UpdateWifiViewController, UpdateWifiParam> {

}

// MARK: - UpdateWifiDelegate
extension UpdateWifiPresenter: UpdateWifiDelegate {

    func load() {
        view.configureView()

        view.setSecurity(param.securityType)
    }

    func selectWifiSecurity() {
        let actions: [UIAlertAction] = WiFiSettings.WiFiSecurity.allCases.map { item in
            UIAlertAction.genericButton(item.rawValue) { [weak self] _ in
                self?.view.setSecurity(item)
            }
        }
        UIAlertController.presentAlert(from: view, title: nil, actions: actions)
    }

    func done() {
        if let ssid = view.ssidField.text,
           let password = view.passwordField.text,
           let securityText = view.securityButton.titleLabel?.text,
           let security = WiFiSettings.WiFiSecurity(rawValue: securityText) {
            param.didChangeSettings(WiFiSettings(enable: true, ssid: ssid, password: password, securityType: security))
            dismiss()
        }
    }

    func dismiss() {
        view.dismiss(animated: true, completion: nil)
    }

}
