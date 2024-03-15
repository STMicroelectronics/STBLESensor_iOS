//
//  DemoListPresenter.swift
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

public final class DemoListPresenter: BasePresenter<DemoListViewController, Node> {
    var director: TableDirector?

    var demos: [Demo] = [Demo]()
    var demosKey: String?

    public override func prepareSettingsMenu() {

        settingsButton.image = ImageLayout.Common.gear?.template
        
        settingActions.removeAll()

        settingActions.append(SettingsAction(name: Localizer.Firmware.Text.upgrade.localized,
                                             handler: { [weak self] in
            guard let self else { return }
            self.view.navigationController?.show(FirmwareSelectPresenter(param: DemoParam<Firmware>(node: self.param)).start(), sender: nil)
        }))
        
        if let sessionService: SessionService = Resolver.shared.resolve(),
           sessionService.permissions.contains(.debugConsole),
           !(Permission.debugConsole.isAuthenticationRequired) {
            if self.param.hasDebugConsole {
                settingActions.append(
                    SettingsAction(
                        name: "Debug Console",
                        handler: { [weak self] in
                            guard let self else { return }
                            self.view.navigationController?.show(DebugConsolePresenter(param: DemoParam<Void>(node: self.param)).start(), sender: nil)
                        }
                    )
                )
            }
        }

        super.prepareSettingsMenu()

        addNavigationButton(with: ImageLayout.Common.edit,
                            selectedImage: ImageLayout.Common.editStop,
                            group: .right) { [weak self] in
            self?.director?.tableView?.isEditing = !(self?.director?.tableView?.isEditing ?? false)
        } selectedHandler: { [weak self] in
            return (self?.director?.tableView?.isEditing ?? false)
        }

    }
}

private extension DemoListPresenter {
    func login() {
        guard let loginService: LoginService = Resolver.shared.resolve() else { return }
        if !loginService.isAuthenticated {
            
            loginService.authenticate(from: self.view) { [weak self] error in
                guard let self else { return }
                if let error = error {
                    UIAlertController.warning(message: error.localizedDescription, from: self.view)
                } else {
                    self.refresh()
                }
            }
        }
    }

    func refresh() {
        prepareSettingsMenu()

        //Check node ble protocol version v2/v1
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog,
           let firmware = catalog.v2Firmware(with: param.deviceId.longHex,
                                             firmwareId: UInt32(param.bleFirmwareVersion).longHex) {

            let defaults = UserDefaults.standard
            demosKey = "demos_\(firmware.uniqueIdentifier)"
            if let data = defaults.data(forKey: "demos_\(firmware.uniqueIdentifier)"),
               let demos = try? JSONDecoder().decode([Demo].self, from: data) {
                let allDemos = Demo.demos(with: param.characteristics.allFeatures())
                if demos.satisfy(array: allDemos) {
                    self.demos = demos
                } else {
                    self.demos = allDemos
                }
            } else {
                demos = Demo.demos(with: param.characteristics.allFeatures())
            }

            Logger.debug(text: "CURRENT FIRMWARE: \(firmware.fullName)")

            if let availableFirmware = catalog.mostRecentAvailableNewV2Firmware(with: param.deviceId.longHex,
                                                                        currentFirmware: firmware),
//               availableFirmware.fota?.type == .wbReady,
               param.protocolVersion ==  0x02,
               let tag = param.tag,
               !BlueManager.shared.isFirmwareUpdateIgnored(availableFirmware, deviceTag: tag) {
                Logger.debug(text: "AVAILABLE FIRMWARE: \(availableFirmware.fullName)")
                
                view.present(
                    UINavigationController(
                        rootViewController: FirmwareCheckerPresenter(
                            param: FirmwareChecker(
                                node: param,
                                firmwares: Firmwares(current: firmware, availables: [ availableFirmware ])
                            )
                        ).start()
                    ),
                    animated: true)
//                view.present(FirmwareCheckerPresenter(param: FirmwareChecker(node: param,
//                                                                         firmwares: Firmwares(current: firmware,
//                                                                                              availables: [ availableFirmware ]))).start(),
//                         animated: true)
            }

            BlueManager.shared.updateDtmi(with: .prod, firmware: firmware) { dtmiElements, error in

            }
        } else if let address = param.address {
            let defaults = UserDefaults.standard
            demosKey = "demos_\(address)"
            if let data = defaults.data(forKey: "demos_\(address)"),
               let demos = try? JSONDecoder().decode([Demo].self, from: data) {
                self.demos = demos
            } else {
                demos = Demo.demos(with: param.characteristics.allFeatures())
            }
        }
        
        if !(param.type == .sensorTileBox || param.type == .sensorTileBoxPro || param.type == .sensorTileBoxProB) {
            demos.removeAll(where: { $0 == .flow })
        } else {
            DispatchQueue.main.async {
                if let dtmi = BlueManager.shared.dtmi(for: self.param) {
                    if let demoDecorator = dtmi.firmware.demoDecorator {
                        if !demoDecorator.add.contains("Flow") {
                            self.demos.removeAll(where: { $0 == .flow })
                        }
                    } else {
                        self.demos.removeAll(where: { $0 == .flow })
                    }
                } else {
                    self.demos.removeAll(where: { $0 == .flow })
                }
            }
        }

        view.tableView.separatorStyle = .singleLine

        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: DemoViewModel.self,
                               type: .fromClass,
                               bundle: .module)
            director?.register(viewModel: NodeHeaderViewModel.self,
                               type: .fromClass,
                               bundle: .module)

            director?.isFirstCellLocked = true
        }

        director?.elements.append(NodeHeaderViewModel(param: param))

        director?.elements.append(contentsOf: demos.enumerated().map({
            DemoViewModel(param: $1, index: $0, isLockedCheckEnabled: true)
        }))

        director?.onSelect({ [weak self] indexPath in
            guard indexPath.row > 0,
                  let self,
                  let viewModel = self.director?.elements[indexPath.row] as? DemoViewModel,
                  let demo = viewModel.param else { return }

            if demo.isLockedForNotExpert && demo.isLocked {
                UIAlertController.presentAlert(
                    from: self.view,
                    title: "Unavailable content",
                    message: "The selected content is unavailable for your proficiency level. Finally, you need to be authenticated to use it.",
                    actions: [
                        UIAlertAction.genericButton(Localizer.Common.ok.localized) { _ in }
                    ]
                )
            } else if demo.isLockedForNotExpert {
                UIAlertController.presentAlert(
                    from: self.view,
                    title: "Unavailable content",
                    message: "The selected content is unavailable for your proficiency level.",
                    actions: [
                        UIAlertAction.genericButton(Localizer.Common.ok.localized) { _ in }
                    ]
                )
            } else if demo.isLocked {
                UIAlertController.presentAlert(
                    from: self.view,
                    title: Localizer.Common.warning.localized,
                    message: Localizer.DemoList.Text.loginNeeded.localized,
                    actions: [
                        UIAlertAction.genericButton(Localizer.Common.ok.localized) { [weak self] _ in
                            self?.login()
                        },
                        UIAlertAction.genericButton(Localizer.Common.cancel.localized) { _ in }
                    ])
            } else {
                self.view.navigationController?.show(demo.presenter(with: self.param).start(), sender: nil)
            }
        })

        director?.onMove({ [weak self] sourceIndexPath, destinationIndexPath in
            guard let self else { return }

            guard let elements = self.director?.elements else { return }

            var index = 0
            for element in elements where element is DemoViewModel {
                guard let element = element as? DemoViewModel else { return }
                element.index = index
                index += 1
            }

            DispatchQueue.main.async {
                guard let visibleIndexPaths = self.view.tableView.indexPathsForVisibleRows else { return }
                self.view.tableView.reloadRows(at: visibleIndexPaths, with: .none)
            }

            let offset = self.director?.isFirstCellLocked ?? false ? 1 : 0

            let demo = self.demos[sourceIndexPath.row - offset]
            self.demos.remove(at: sourceIndexPath.row - offset)
            self.demos.insert(demo, at: destinationIndexPath.row - offset)

            guard let demosKey = self.demosKey,
            let data = try? JSONEncoder().encode(self.demos) else { return }
            let defaults = UserDefaults.standard

            defaults.set(data, forKey: demosKey)

        })

        director?.reloadData()
    }
}

// MARK: - DemoListDelegate
extension DemoListPresenter: DemoListDelegate {

    public func load() {
        view.configureView()

        refresh()
    }

    public func disconnect() {
        BlueManager.shared.disconnect(param)
    }

    public func openWebPage() {
        
    }

}


extension Array where Element: Equatable {
    func satisfy(array: [Element]) -> Bool {
        return self.allSatisfy(array.contains)
    }
}
