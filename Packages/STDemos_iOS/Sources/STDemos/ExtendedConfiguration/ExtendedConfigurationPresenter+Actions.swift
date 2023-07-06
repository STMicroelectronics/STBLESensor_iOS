//
//  ExtendedConfigurationPresenter+Actions.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI
import STCore
import Toast

public extension Date {
    var nowDateFormattedForBoard: String {
        let df = DateFormatter()
        df.dateFormat = "ee"
        df.locale = Locale(identifier: "IT-it")
        let weekDay = Int(df.string(from: self)) ?? 0

        df.dateFormat = "dd/MM/YY"
        let dateString = df.string(from: self)

        return "\(String(format: "%02d", weekDay))/\(dateString)"
    }

    var nowTimeFormattedForBoard: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "IT-it")
        df.dateFormat = "HH:mm:ss"

        return df.string(from: self)
    }
}

extension ExtendedConfigurationPresenter {
    internal func sendCommand(_ command: ECCommandType) {
        switch command {
        case .UID, .versionFw, .info, .help, .powerStatus, .clearDB, .DFU, .off, .readCustomCommand, .readBankStatus:
            BlueManager.shared.sendECCommand(command, to: param.node)
        case .setName:
            showSetNameAlert()
        case .setTime:
            BlueManager.shared.sendECCommand(.setTime,
                                             string: Date().nowTimeFormattedForBoard,
                                             to: param.node)
        case .setDate:
            BlueManager.shared.sendECCommand(.setDate,
                                             string: Date().nowDateFormattedForBoard,
                                             to: param.node)
        case .changePIN:
            showChangePINAlert()
        case .bankSwap:
            bankSwap()
        case .setWiFi:
            showSetWiFiCredentialsAlert()
        default:
            break
//            case .readCert:
//                setLoadingUIVisible(true)
//                feature?.sendCommand(command)
//            case .setCert:
//                requestCertificate()
//            case .readSensorsConfig:
//                showSensors()
        }

        if let text = command.executedPhrase {
            view.view.makeToast(text.localized)
        }
    }

    internal func setName(_ name: String) {
        let nameToSend = name.padding(toLength: 7, withPad: " ", startingAt: 0)

        BlueManager.shared.sendECCommand(.setName, string: nameToSend, to: self.param.node)
        view.view.makeToast("The Board will change the name after the disconnection.")
    }

    internal func changePin(_ pin: String) {
        BlueManager.shared.sendECCommand(.changePIN, string: pin, to: self.param.node)
        view.view.makeToast("The Board will use the new PIN.")
    }

    internal func bankSwap() {
        BlueManager.shared.sendECCommand(.bankSwap, to: param.node)
        view.view.makeToast("The Board will reboot after the disconnection.")
    }

    internal func sendWiFiSettings(_ wifisettings: WiFiSettings) {
        BlueManager.shared.sendECCommand(.setWiFi, json: wifisettings, to: param.node)
        view.view.makeToast("Wi-Fi Credential Sent to Board.")
    }

    internal func showSetNameAlert() {
        let limit = 7
        var aTextField: UITextField?
        let confirmButton = UIAlertAction.genericButton(Localizer.Common.ok.localized) { [weak self] _ in
            if let text = aTextField?.text, !text.isEmpty {
                self?.setName(text)
            }
        }

        UIAlertController.presentTextFieldAlert(from: view,
                                                title: Localizer.Extconf.Command.Text.commandSetNameAlertTitle.localized,
                                                message: "",
                                                confirmButton: confirmButton,
                                                cancelButton: UIAlertAction.cancelButton()) { [weak self] textfield, controller in
            aTextField = textfield
            textfield.placeholder = self?.param.node.name
            textfield.onKeyPress { [weak controller] text in
                let isValid = text.count <= limit
                defer {
                    if isValid { controller?.message = "\(text.count)/\(limit)" }
                }
                return isValid
            }
        }
    }

    internal func showChangePINAlert() {
        let limit = 6
        var aTextField: UITextField?
        let confirmButton = UIAlertAction.genericButton(Localizer.Common.ok.localized) { [weak self] _ in
            if let text = aTextField?.text, !text.isEmpty {
                self?.changePin(text)
            }
        }
        UIAlertController.presentTextFieldAlert(from: view,
                                                title: Localizer.Extconf.Command.Text.commandChangePINAlertTitle.localized,
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

    internal func showFlashBankStatus(_ status: BankStatusResponse?) {
        guard let status = status else { return }
        view.present(FlashBankStatusPresenter(param: FlashBank(bankStatus: status, node: param.node)).start().embeddedInNav(),
                     animated: true)
    }

    internal func showSetWiFiCredentialsAlert() {
        view.present(UpdateWifiPresenter(param: UpdateWifiParam(securityType: .OPEN,
                                                                didChangeSettings: { [weak self] settings in
            guard let self else { return }
            self.sendWiFiSettings(settings)

        })).start().embeddedInNav(), animated: true)
    }
}

