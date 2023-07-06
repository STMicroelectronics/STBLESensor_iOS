//
//  FlashBankStatusPresenter+Actions.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import Toast
import STBlueSDK
import STCore

extension FlashBankStatusPresenter {
    func bankSwap() {
        BlueManager.shared.sendECCommand(.bankSwap, to: param.node)
        view.view.makeToast("The Board will reboot after the disconnection.")
    }

    func installSelectedFirmware() {
        guard let selectedFirmware = selectedFirmware else { return }

        let viewModel = FirmwareSelectPresenter(param: DemoParam(node: param.node, param: selectedFirmware))

        view.navigationController?.pushViewController(viewModel.start(), animated: true)
    }
}
