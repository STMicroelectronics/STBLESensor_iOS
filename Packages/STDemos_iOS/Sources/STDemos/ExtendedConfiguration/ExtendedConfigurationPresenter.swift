//
//  ExtendedConfigurationPresenter.swift
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
import STCore

final class ExtendedConfigurationPresenter: DemoPresenter<ExtendedConfigurationViewController> {

    var uid: String = ""

    var availableCommands: [ECCommandType] = []
    var customCommands: [ECCustomCommand] = []

    var model: [ECCommandSection] = []
    var expandedSections: Set<ECCommandSection> = [.boardReport, .boardSecurity, .boardControl, .boardSettings, .customCommands]

    var director: TableDirector?

    public func showAlert(title: String?, message: String?, actions: [UIAlertAction] = [ UIAlertAction.genericButton() ]) {
        UIAlertController.presentAlert(from: view,
                                       title: title,
                                       message: message,
                                       actions: actions)
    }


    public func showTextFieldAlert(title: String?,
                                   message: String?,
                                   confirmButton: UIAlertAction,
                                   cancelButton: UIAlertAction = UIAlertAction.cancelButton(),
                                   textFieldConfiguration: @escaping (UITextField, UIAlertController) -> Void) {
        UIAlertController.presentTextFieldAlert(from: view,
                                                title: title,
                                                confirmButton: confirmButton,
                                                textFieldConfiguration: textFieldConfiguration)
    }
}

private extension ExtendedConfigurationPresenter {

    func commandListUpdated(_ sectionsAvailable: [ECCommandType]) {
        availableCommands = sectionsAvailable

        reloadModels()

        if uid.isEmpty {
            self.sendCommand(.UID)
        }

    }

    func reloadModels() {
        model = [ .boardReport, .boardSecurity, .boardControl, .boardSettings ]

        model.forEach {
            Logger.debug(text: $0.title.localized)
        }

        if !customCommands.isEmpty {
            model.append(.customCommands)
        }

        let commandViewmodels = model.map { [weak self] in

            let image = ImageLayout.image(with: $0.iconName, in: .module)?.maskWithColor(color: ColorLayout.secondary.light)?.addPadding(20.0)

            let headerViewModel = [
                ImageDetailViewModel(param: CodeValue<ImageDetail>(keys: [ UUID().uuidString ],
                                                               value: ImageDetail(title: $0.title.localized,
                                                                                  subtitle: $0.title.localized,
                                                                                  image: image)),
                                     layout: Layout.standard)
                ]

            if $0 == .customCommands {
                let commandViewModels = self?.customCommands.map { command in
                    return LabelViewModel(param: CodeValue<String>(keys: [ UUID().uuidString ], value: command.name),
                                   layout:Layout.standard) { [weak self] param in

                        Logger.debug(text: param.keys.joined(separator: "-"))

                        self?.sendCustomCommand(command)
                    }
                }

                return GroupCellViewModel(childViewModels: headerViewModel + (commandViewModels ?? []),
                                     isOpen: true)
            } else {
                let commandViewModels = $0.commands.map { command in
                    let isEnabled = self?.availableCommands.contains(command) ?? false

                    return LabelViewModel(param: CodeValue<String>(keys: [ command.rawValue ], value: command.title.localized),
                                   layout: isEnabled ? Layout.standard : Layout.disabled) { [weak self] param in

                        Logger.debug(text: param.keys.joined(separator: "-"))

                        guard let self, isEnabled else { return }

                        self.sendCommand(command)
                    }
                }

                return GroupCellViewModel(childViewModels: headerViewModel + commandViewModels,
                                     isOpen: true)
            }

        }

        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
        }

        director?.elements.removeAll()
        director?.elements.append(contentsOf: commandViewmodels)

        director?.onSelect({ indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")
        })

        director?.reloadData()

        view.configureView()
    }
}

// MARK: - ExtendedConfigurationDelegate
extension ExtendedConfigurationPresenter: ExtendedConfigurationDelegate {

    func manageResponse(response: ECResponse) {
        guard let type = response.type else { return }

        let alertTitle = type.title.localized

        switch type {
        case .readCommand:
            self.commandListUpdated(response.availableCommands)

        case .UID:
            let newUID = response.UID ?? ""
            if uid.isEmpty {
                uid = newUID
            } else {
                showAlert(title: alertTitle, message: newUID)
            }

        case .versionFw, .info, .help, .powerStatus:
            showAlert(title: alertTitle, message: response.stringValue ?? "")

        case .readCustomCommand:
            customCommands = response.customCommands ?? []
            reloadModels()

        case .readCert:
            //                showCertificate(response.stringValue)
            break

        case .readBankStatus:
            showFlashBankStatus(response.bankStatus)

        default:
            break
        }
    }

    func load() {

        demo = .extendedConfiguration

        view.title = demo?.title

        demoFeatures = param.node.characteristics.features(with: Demo.extendedConfiguration.features)

        view.configureView()

        BlueManager.shared.sendECCommand(.readCommand, to: param.node)
    }

}
