//
//  JsonNfcViewController.swift
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

final class JsonNfcViewController: DemoNodeViewController<JsonNfcDelegate, JsonNfcView> {

    public static let commandReadModes = "ReadModes"
    public static let commandWiFi = "NFCWiFi"
    public static let commandVCard = "NFCVCard"
    public static let commandUrl = "NFCURL"
    public static let commandText = "GenericText"
    
    public let wiFiEncryptionStrings: [WifiEncryption] = [
        WifiEncryption(Localizer.JsonNfc.Encryption.none.localized, 1),
        WifiEncryption(Localizer.JsonNfc.Encryption.wep.localized, 2),
        WifiEncryption(Localizer.JsonNfc.Encryption.tkip.localized, 4),
        WifiEncryption(Localizer.JsonNfc.Encryption.aes.localized, 8),
    ]
    
    let wiFiAuthenticationStrings: [WifiAuthenticationString] = [
        WifiAuthenticationString(Localizer.JsonNfc.Authentication.none.localized, 1),
        WifiAuthenticationString(Localizer.JsonNfc.Authentication.wpapsk.localized, 2),
        WifiAuthenticationString(Localizer.JsonNfc.Authentication.shared.localized, 4),
        WifiAuthenticationString(Localizer.JsonNfc.Authentication.wpa.localized, 8),
        WifiAuthenticationString(Localizer.JsonNfc.Authentication.wpa2.localized, 16),
        WifiAuthenticationString(Localizer.JsonNfc.Authentication.wpatwopsk.localized, 32),
    ]
    
    public let urlHeaderStrings: [UrlHeaderString] = [
        UrlHeaderString("http://www.", 1),
        UrlHeaderString("https://www.", 2),
    ]
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.jsonNfc.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        mainView.headerUrlLabel.text = urlHeaderStrings[0].displayName
        
        mainView.authenticationTypeLabel.text = wiFiAuthenticationStrings[0].displayName
        mainView.encryptionTypeLabel.text = wiFiEncryptionStrings[0].displayName
        
        let choiceHeaderUrlBtnTap = UITapGestureRecognizer(target: self, action: #selector(urlChoiceBtnTapped(_:)))
        mainView.urlHeaderBtn.addGestureRecognizer(choiceHeaderUrlBtnTap)
        
        let choiceAuthenticationBtnTap = UITapGestureRecognizer(target: self, action: #selector(authenticationChoiceBtnTapped(_:)))
        mainView.authenticationBtn.addGestureRecognizer(choiceAuthenticationBtnTap)
        let choiceEncryptionBtnTap = UITapGestureRecognizer(target: self, action: #selector(encryptionChoiceBtnTapped(_:)))
        mainView.encryptionBtn.addGestureRecognizer(choiceEncryptionBtnTap)
        
        let textWriteBtnTap = UITapGestureRecognizer(target: self, action: #selector(textWriteBtnTapped(_:)))
        mainView.textWriteBtn.addGestureRecognizer(textWriteBtnTap)
        let urlWriteBtnTap = UITapGestureRecognizer(target: self, action: #selector(urlWriteBtnTapped(_:)))
        mainView.urlWriteBtn.addGestureRecognizer(urlWriteBtnTap)
        let wifiWriteBtnTap = UITapGestureRecognizer(target: self, action: #selector(wifiWriteBtnTapped(_:)))
        mainView.wifiWriteBtn.addGestureRecognizer(wifiWriteBtnTap)
        let vCardWriteBtnTap = UITapGestureRecognizer(target: self, action: #selector(vcardtWriteBtnTapped(_:)))
        mainView.vcardWriteBtn.addGestureRecognizer(vCardWriteBtnTap)
    }

}

extension JsonNfcViewController {
    
    @objc
    func urlChoiceBtnTapped(_ sender: UITapGestureRecognizer) {
        var actions: [UIAlertAction] = []
        for i in 0...(urlHeaderStrings.count - 1) {
            actions.append(UIAlertAction.genericButton(urlHeaderStrings[i].displayName) { [weak self] _ in
                self?.mainView.headerUrlLabel.text = self?.urlHeaderStrings[i].displayName
            })
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentAlert(from: self, title: "Select Value", actions: actions)
    }
    
    @objc
    func authenticationChoiceBtnTapped(_ sender: UITapGestureRecognizer) {
        var actions: [UIAlertAction] = []
        for i in 0...(wiFiAuthenticationStrings.count - 1) {
            actions.append(UIAlertAction.genericButton(wiFiAuthenticationStrings[i].displayName) { [weak self] _ in
                self?.mainView.authenticationTypeLabel.text = self?.wiFiAuthenticationStrings[i].displayName
            })
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentAlert(from: self, title: "Select Value", actions: actions)
    }
    
    @objc
    func encryptionChoiceBtnTapped(_ sender: UITapGestureRecognizer) {
        var actions: [UIAlertAction] = []
        for i in 0...(wiFiEncryptionStrings.count - 1) {
            actions.append(UIAlertAction.genericButton(wiFiEncryptionStrings[i].displayName) { [weak self] _ in
                self?.mainView.encryptionTypeLabel.text = self?.wiFiEncryptionStrings[i].displayName
            })
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentAlert(from: self, title: "Select Value", actions: actions)
    }
    
    @objc
    func textWriteBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.writeTextOnNfc()
    }
    @objc
    func urlWriteBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.writeUrlOnNfc()
    }
    @objc
    func wifiWriteBtnTapped(_ sender: UITapGestureRecognizer) {
        
        var wifiAuthenticationRawValue = 0
        var wifiEncryptionRawValue = 0
        
        self.wiFiAuthenticationStrings.forEach { authenticationType in
            if(authenticationType.displayName == mainView.authenticationTypeLabel.text) {
                wifiAuthenticationRawValue = authenticationType.rawValue
            }
        }
        wiFiEncryptionStrings.forEach { encryptionType in
            if(encryptionType.displayName == mainView.encryptionTypeLabel.text) {
                wifiEncryptionRawValue = encryptionType.rawValue
            }
        }
        
        presenter.writeWifiOnNfc(wifiAuthenticationRawValue, wifiEncryptionRawValue)
    }
    @objc
    func vcardtWriteBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.writeVcardOnNfc()
    }
}
