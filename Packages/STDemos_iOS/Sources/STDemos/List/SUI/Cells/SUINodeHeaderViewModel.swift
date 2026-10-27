//
//  SUINodeHeaderViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI
import STBlueSDK
import STCore

@MainActor
final class SUINodeHeaderViewModel: ObservableObject {

    let node: Node

    @Published private(set) var firmwareFullName: String?
    @Published private(set) var customDtmiText: String?
    @Published private(set) var customDtmiColor: Color = SUIColorLayout.accent.color

    init(node: Node) {
        self.node = node
        configure()
    }

    private func configure() {

        guard node.protocolVersion == 0x02 else { return }

        guard
            let catalogService: CatalogService = Resolver.shared.resolve(),
            let catalog = catalogService.catalog,
            let firmware = catalog.v2Firmware(
                with: node.deviceId.longHex,
                firmwareId: UInt32(node.bleFirmwareVersion).longHex
            )
        else { return }

        if !firmware.fullName.isEmpty {
            firmwareFullName = firmware.fullName
        }

        guard firmware.bleVersionId == 255 else { return }

        Demo.demos(with: node.characteristics.allFeatures(), node: node) { [weak self] demos in

            guard let self else { return }

            let hasPnPL = Set([Demo.pnpLike]).isSubset(of: Set(demos))
            guard hasPnPL else { return }

            Task { @MainActor in
                if catalogService.customDtmi == nil {
                    self.customDtmiText = "Custom DTMI not present"
                    self.customDtmiColor = SUIColorLayout.accent.color
                } else {
                    self.customDtmiText = "Custom DTMI"
                    self.customDtmiColor = SUIColorLayout.green.color
                }
            }
        }
    }
}

extension Node {
    var image: UIImage? {
        guard let imageName = type.imageName else { return nil }
        return UIImage(named: imageName, in: STUI.bundle, compatibleWith: nil)
    }
}
