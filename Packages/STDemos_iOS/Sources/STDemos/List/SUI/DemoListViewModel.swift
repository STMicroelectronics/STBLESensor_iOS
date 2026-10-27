//
//  DemoListViewModel.swift
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
final class DemoListViewModel: ObservableObject {

    let node: Node
    var onNodeDisconnected: (() -> Void)?

    @Published var demos: [Demo] = []
    @Published var alertInfo: AlertInfo?
    @Published var selectedDestination: Destination?
    @Published var isFirmwareCheckerPresented = false
    @Published var firmwareCheckerConfiguration: SUIFirmwareChecker?
    @Published private(set) var canDebugConsole = false

    private var demosKey: String?
    private var hasEvaluatedFirmwareUpdate = false

    private lazy var connectionObserver = NodeConnectionObserver(
        currentNode: node,
        onNodeDisconnected: { [weak self] in
            guard let self else { return }
            self.selectedDestination = nil
            self.dismissFirmwareChecker()
            self.onNodeDisconnected?()
        }
    )
    
    func startObservingConnection() {
        connectionObserver.start()
    }
    
    func stopObservingConnection() {
        connectionObserver.stop()
    }
    
    enum Destination: Identifiable, Hashable {
        case demo(Demo)
        case firmwareUpgrade(SUIFirmwareSelect)
        case debugConsole

        var id: String {
            switch self {
            case .demo(let demo): return "demo_\(demo.title)"
            case .firmwareUpgrade(let configuration): return "firmwareUpgrade_\(configuration.id)"
            case .debugConsole: return "debugConsole"
            }
        }
    }

    struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let showsLoginAction: Bool
    }

    init(node: Node) {
        self.node = node
    }

    func load() {

        Demo.demos(with: node.characteristics.allFeatures(), node: node) { [weak self] allDemos in
            guard let self else { return }

            Task { @MainActor in
                self.applyDemos(allDemos)
            }
        }
    }

    private func applyDemos(_ allDemos: [Demo]) {

        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog,
           let firmware = catalog.v2Firmware(
                with: node.deviceId.longHex,
                firmwareId: UInt32(node.bleFirmwareVersion).longHex
           ) {

            let defaults = UserDefaults.standard
            demosKey = "demos_\(firmware.uniqueIdentifier)"

            if let data = defaults.data(forKey: "demos_\(firmware.uniqueIdentifier)"),
               let savedDemos = try? JSONDecoder().decode([Demo].self, from: data),
               savedDemos.satisfy(array: allDemos) {
                demos = savedDemos
            } else {
                demos = allDemos
            }

            Logger.debug(text: "CURRENT FIRMWARE: \(firmware.fullName)")

            if !hasEvaluatedFirmwareUpdate,
               let availableFirmware = catalog.mostRecentAvailableNewV2Firmware(
                    with: node.deviceId.longHex,
                    currentFirmware: firmware
               ),
               node.protocolVersion == 0x02,
               let tag = node.tag,
               !BlueManager.shared.isFirmwareUpdateIgnored(availableFirmware, deviceTag: tag) {
                hasEvaluatedFirmwareUpdate = true
                Logger.debug(text: "AVAILABLE FIRMWARE: \(availableFirmware.fullName)")

                let configuration = SUIFirmwareChecker(
                    node: node,
                    firmwares: Firmwares(current: firmware, availables: [availableFirmware]),
                    completion: nil
                )
                firmwareCheckerConfiguration = configuration
                isFirmwareCheckerPresented = true
            }

            BlueManager.shared.updateDtmi(with: .prod, firmware: firmware) { dtmiElements, error in
                if dtmiElements.isEmpty || error != nil {
                    BlueManager.shared.updateDtmi(with: .dev, firmware: firmware) { _, _ in }
                }
            }

        } else if let address = node.address {
            let defaults = UserDefaults.standard
            demosKey = "demos_\(address)"
            if let data = defaults.data(forKey: "demos_\(address)"),
               let savedDemos = try? JSONDecoder().decode([Demo].self, from: data) {
                demos = savedDemos
            } else {
                demos = allDemos
            }
        }

        if let sessionService: SessionService = Resolver.shared.resolve() {
            canDebugConsole = sessionService.permissions.contains(.debugConsole)
                && !Permission.debugConsole.isAuthenticationRequired
                && node.hasDebugConsole
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        demos.move(fromOffsets: source, toOffset: destination)
        persistDemos()
    }

    private func persistDemos() {
        guard let demosKey, let data = try? JSONEncoder().encode(demos) else { return }
        UserDefaults.standard.set(data, forKey: demosKey)
    }

    func select(_ demo: Demo) {

        if demo.isLockedForNotExpert && demo.isLocked {
            alertInfo = AlertInfo(
                title: "Unavailable content",
                message: "The selected content is unavailable for your proficiency level. Finally, you need to be authenticated to use it.",
                showsLoginAction: false
            )
        } else if demo.isLockedForNotExpert {
            alertInfo = AlertInfo(
                title: "Unavailable content",
                message: "The selected content is unavailable for your proficiency level.",
                showsLoginAction: false
            )
        } else if demo.isLocked {
            alertInfo = AlertInfo(
                title: Localizer.Common.warning.localized,
                message: Localizer.DemoList.Text.loginNeeded.localized,
                showsLoginAction: true
            )
        } else {
            selectedDestination = .demo(demo)
        }
    }

    func dismissFirmwareChecker() {
        isFirmwareCheckerPresented = false
        firmwareCheckerConfiguration = nil
    }

    func openFirmwareUpgrade(
        firmware: Firmware? = nil,
        isMandatory: Bool = false,
        completion: ((Bool) -> Void)? = nil
    ) {
        dismissFirmwareChecker()

        Task { @MainActor in
            await Task.yield()
            selectedDestination = .firmwareUpgrade(
                SUIFirmwareSelect(
                    node: node,
                    firmware: firmware,
                    isMandatory: isMandatory,
                    completion: completion
                )
            )
        }
    }

    func disconnectIfLeavingDemoList() {
        guard selectedDestination == nil, !isFirmwareCheckerPresented else { return }
        BlueManager.shared.disconnect(node)
    }
}

extension Array where Element: Equatable {
    func satisfy(array: [Element]) -> Bool {
        allSatisfy(array.contains)
    }
}
