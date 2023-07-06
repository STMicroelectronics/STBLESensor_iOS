//
//  JsonNfcPresenter.swift
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
import Toast

final class JsonNfcPresenter: DemoPresenter<JsonNfcViewController> {

}

// MARK: - JsonNfcViewControllerDelegate
extension JsonNfcPresenter: JsonNfcDelegate {

    func load() {
        
        demo = .jsonNfc
        
        demoFeatures = param.node.characteristics.features(with: Demo.jsonNfc.features)
        
        view.title = Localizer.JsonNfc.Text.demoTitle.localized
        
        view.configureView()
    }
    
    func writeTextOnNfc() {
        guard let text = view.mainView.textTF.text else {
            view.mainView.makeToast("Please insert a text.")
            return
        }
        
        let jsonWriteCmd = JsonWriteCommand<String>(
            command: nil,
            genericText: text,
            nfcWiFi: nil,
            nfcVCard: nil,
            nfcURL: nil
        )
        sendJsonCommand(jsonWriteCmd, "Text NDEF Record Written on NFC")
    }
    
    func writeUrlOnNfc() {
        guard let url = view.mainView.urlTF.text else {
            view.mainView.makeToast("Please insert URL address")
            return
        }
        
        let jsonWriteCmd = JsonWriteCommand<String>(
            command: nil,
            genericText: nil,
            nfcWiFi: nil,
            nfcVCard: nil,
            nfcURL: "\(view.mainView.headerUrlLabel.text ?? "")\(url)"
        )
        sendJsonCommand(jsonWriteCmd, "URL NDEF Record Written on NFC")
    }
    
    func writeWifiOnNfc(_ wifiAuthenticationRawValue: Int, _ wifiEncryptionRawValue: Int) {
        guard let ssid = view.mainView.ssidWiFiTF.text else {
            view.mainView.makeToast("Please insert SSID")
            return
        }
        
        let jsonWriteCmd = JsonWriteCommand<String>(
            command: nil,
            genericText: nil,
            nfcWiFi: JsonWIFI(
                networkSSID: ssid,
                networkKey: extractTextFromTF(view.mainView.passwordWiFiTF),
                authenticationType: wifiAuthenticationRawValue,
                encryptionType: wifiEncryptionRawValue),
            nfcVCard: nil,
            nfcURL: nil
        )
        sendJsonCommand(jsonWriteCmd, "WiFi NDEF Record Written on NFC")
    }
    
    func writeVcardOnNfc() {
        let jsonWriteCmd = JsonWriteCommand<String>(
            command: nil,
            genericText: nil,
            nfcWiFi: nil,
            nfcVCard: JsonVCard(
                name: extractTextFromTF(view.mainView.nameVCardTF),
                formattedName: extractTextFromTF(view.mainView.formattedNameVCardTF),
                title: extractTextFromTF(view.mainView.titleVcardTF),
                org: extractTextFromTF(view.mainView.organizationVcardTF),
                homeAddress: extractTextFromTF(view.mainView.homeAddressVcardTF),
                workAddress: extractTextFromTF(view.mainView.workAdressVcardTF),
                address: extractTextFromTF(view.mainView.addressVcardTF),
                homeTel: extractTextFromTF(view.mainView.homePhoneVcardTF),
                workTel: extractTextFromTF(view.mainView.workPhoneVcardTF),
                cellTel: extractTextFromTF(view.mainView.cellularPhoneVcardTF),
                homeEmail: extractTextFromTF(view.mainView.homeEmailVcardTF),
                workEmail: extractTextFromTF(view.mainView.workEmailVcardTF),
                url: extractTextFromTF(view.mainView.urlVcardTF)
            ),
            nfcURL: nil
        )

        guard let feature = demoFeatures.first else { return }

        BlueManager.shared.sendJsonCommand(StandardJsonCommand(value: jsonWriteCmd),
                                           to: param.node,
                                           feature: feature)
        sendJsonCommand(jsonWriteCmd, "WiFi NDEF Record Written on NFC")
    }
    
    private func extractTextFromTF(_ tf: UITextField) -> String? {
        if(tf.text != nil && tf.text != ""){
            return tf.text
        } else {
            return nil
        }
    }
    
    private func sendJsonCommand(_ command: JsonWriteCommand<String>, _ message: String) {
        if let jsonNFCFeature = param.node.characteristics.first(with: JsonNFCFeature.self) {
            
            BlueManager.shared.sendJsonCommand(
                StandardJsonCommand(value: command),
                to: param.node,
                feature: jsonNFCFeature
            )
            
            view.mainView.makeToast(message)
        }
    }
}
