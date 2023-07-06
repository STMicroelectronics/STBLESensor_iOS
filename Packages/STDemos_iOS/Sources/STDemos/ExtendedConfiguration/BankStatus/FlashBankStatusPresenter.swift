//
//  FlashBankStatusPresenter.swift
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

struct FlashBank {
    let bankStatus: BankStatusResponse
    let node: Node
}

final class FlashBankStatusPresenter: BasePresenter<FlashBankStatusViewController, FlashBank> {

    internal static let selectedFirmwareKey = "selectedFirmwareKey"
    internal static let installFirmwareKey = "installFirmwareKey"

    var director: TableDirector?
    var selectedFirmware: Firmware?
}

// MARK: - BankStatusDelegate
extension FlashBankStatusPresenter: FlashBankStatusDelegate {

    func load() {
        view.configureView()

        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
        }

        director?.elements.removeAll()

        configureHeaderViewmodels()
        configureAvailableUpdateViewmodels()
        configureAvailableFirmwareListViewModels()

        director?.onSelect({ indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")
        })

        director?.reloadData()
    }

}
