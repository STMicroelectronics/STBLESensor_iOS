//
//  FirmwareListPresenter.swift
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

final class FirmwareListPresenter: BasePresenter<FirmwareListViewController, Board> {
    var director: TableDirector?
}

// MARK: - FirmwareListDelegate
extension FirmwareListPresenter: FirmwareListDelegate {

    func load() {
        view.configureView()

        if director == nil {
            director = TableDirector(with: view.tableView)

            director?.register(viewModel: FirmwareViewModel.self,
                               type: .fromClass,
                               bundle: .main
            )
        }

        guard let catalogService: CatalogService = Resolver.shared.resolve() else { return }

        let firmwares = catalogService.catalog?.availableV2Firmwares(with: param.deviceId, currentFirmware: nil)

        firmwares?.map { FirmwareViewModel(param: $0) }.forEach { element in
            director?.elements.append(element)
        }

        director?.onSelect({ [weak self ]indexPath in
            guard let viewModel = self?.director?.elements[indexPath.row] as? FirmwareViewModel,
            let firmware = viewModel.param else { return }

            Logger.debug(text: "SELCTED FIRMWARE: \(firmware.fullName)")

        })

        director?.reloadData()
    }

}
