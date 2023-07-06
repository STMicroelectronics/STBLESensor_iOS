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

    public init(node: Node, firmwares: Firmwares) {
        self.node = node
        self.firmwares = firmwares
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
                self.view.dismiss(animated: true)
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
        let viewModel = FirmwareSelectPresenter(param: DemoParam(node: param.node, param: selectedFirmware))
        view.navigationController?.pushViewController(viewModel.start(), animated: true)
    }
    
}
