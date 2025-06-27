//
//  FirmwareCheckerPresenter.swift
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
import STCore
import STBlueSDK

public struct FirmwareChecker {
    public let node: Node
    public let firmwares: Firmwares
    public let completion: ((Bool) -> ())?

    public init(node: Node, firmwares: Firmwares, completion: ((Bool) -> ())? = nil) {
        self.node = node
        self.firmwares = firmwares
        self.completion = completion
    }
}

public final class FirmwareCheckerPresenter: BasePresenter<FirmwareCheckerViewController, FirmwareChecker> {

    var director: TableDirector?

}

// MARK: - FirmwareCheckerDelegate
extension FirmwareCheckerPresenter: FirmwareCheckerDelegate {

    public func load() {
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FirmwareCheckerViewModel.self, bundle: STDemos.bundle)
        }

        view.configureView()

        director?.onSelect({ indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")
        })

        director?.elements.append(FirmwareCheckerViewModel(param: param.firmwares, completion: { [weak self] action in

            guard let self else { return }

            switch action {
            case .cancel(let dontAskAgain):
                Logger.debug(text: "CANCEL: \(dontAskAgain)")
                if dontAskAgain, let tag = self.param.node.tag {
                    self.param.firmwares.availables.forEach { BlueManager.shared.ignoreFirmwareUpdate($0, deviceTag: tag) }
                }

                if self.view.presentingViewController != nil {
                    if let completion = self.param.completion { // }, self?.param.firmwares.isMandatory ?? false {
                        completion(false)
                    }
                    self.view.dismiss(animated: true) { [weak self] in
                        if let node = self?.param.node {
                            BlueManager.shared.disconnect(node)
                        }
                    }
                } else {
                    if let completion = self.param.completion { // }, self?.param.firmwares.isMandatory ?? false {
                        completion(false)
                    }
                    self.view.navigationController?.popViewController(animated: true,
                                                                      completion: { [] in
                    })
                }

            case .install(let firmware, let dontAskAgain):
                if dontAskAgain, let tag = self.param.node.tag {
                    self.param.firmwares.availables.forEach { BlueManager.shared.ignoreFirmwareUpdate($0, deviceTag: tag) }
                }
                Logger.debug(text: "INSTALL: \(firmware.fullName) - \(dontAskAgain)")
                self.installSelectedFirmware(firmware)
            }
        }))

        director?.reloadData()
    }

    func installSelectedFirmware(_ selectedFirmware: Firmware) {
        let viewModel = FirmwareSelectPresenter(param: DemoParam(node: param.node, param: FirmwareSelect(firmware: selectedFirmware, 
                                                                                                         isMandatory: param.firmwares.isMandatory,
                                                                                                         completion: param.completion)))
        view.navigationController?.pushViewController(viewModel.start(), animated: true)
    }
    
}
