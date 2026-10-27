//
//  FirmwareListViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK
import STCore

@MainActor
final class FirmwareListViewModel: ObservableObject {

    @Published private(set) var firmwares: [Firmware] = []

    private let filter: FirmwareFilter

    init(filter: FirmwareFilter) {
        self.filter = filter
    }

    func load() {
        guard let catalogService: CatalogService = Resolver.shared.resolve() else { return }

        let result = catalogService.catalog?.availableV2Firmwares(
            with: filter.board.deviceId,
            names: filter.firmwareNamesFilter,
            supportedVersions: filter.firmwareSupportedVersions
        )?.filter { $0.maturity == .release }

        firmwares = result ?? []
    }

    func didSelect(_ firmware: Firmware) {
        Logger.debug(text: "SELCTED FIRMWARE: \(firmware.fullName)")
    }
}
