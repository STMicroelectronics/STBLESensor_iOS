//
//  SUIFirmwareCheckerView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK
import STCore

@MainActor
public final class SUIFirmwareCheckerViewModel: ObservableObject {

    let node: Node
    let firmwares: Firmwares
    let completion: ((Bool) -> Void)?

    @Published var dontAskAgain: Bool = false

    public init(node: Node, firmwares: Firmwares, completion: ((Bool) -> Void)? = nil) {
        self.node = node
        self.firmwares = firmwares
        self.completion = completion
    }

    var updateFirmware: Firmware? { firmwares.availables.first }

    var updateHeadline: String {
        firmwares.isMandatory ? "Suggested firmware" : "Update Available"
    }

    var infoNote: String {
        firmwares.isMandatory
            ? "PLEASE NOTE: the current firmware is not supported. You need to install the suggested firmware in order to use the app"
            : "PLEASE NOTE: Firmware update always available under Board Configuration → Firmware Download"
    }

    var showsChangelog: Bool {
        !(updateFirmware?.changelog?.isEmpty ?? true)
    }

    // MARK: - Actions
    func handle(_ action: SUIFirmwareCheckerAction, isPresentedModally: Bool, onFinished: @escaping () -> Void, onInstall: @escaping (Firmware) -> Void) {
        switch action {
        case .cancel(let dontAskAgain):
            Logger.debug(text: "CANCEL: \(dontAskAgain)")
            applyIgnoreIfNeeded(dontAskAgain)
            completion?(false)
            if isPresentedModally {
                onFinished()
                BlueManager.shared.disconnect(node)
            } else {
                onFinished()
            }

        case .install(let firmware, let dontAskAgain):
            applyIgnoreIfNeeded(dontAskAgain)
            Logger.debug(text: "INSTALL: \(firmware.fullName) - \(dontAskAgain)")
            onInstall(firmware)
        }
    }

    private func applyIgnoreIfNeeded(_ dontAskAgain: Bool) {
        guard dontAskAgain, let tag = node.tag else { return }
        firmwares.availables.forEach { BlueManager.shared.ignoreFirmwareUpdate($0, deviceTag: tag) }
    }
}
