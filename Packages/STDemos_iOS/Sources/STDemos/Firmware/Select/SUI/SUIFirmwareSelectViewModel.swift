//
//  SUIFirmwareSelectViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//

import Foundation
import STBlueSDK
import STCore

@MainActor
public final class SUIFirmwareSelectViewModel: ObservableObject {

    enum Board: String, CaseIterable, Identifiable, Hashable {
        case wba5 = "WBA5x"
        case wb55 = "WB5x/WB3x"
        case wb09 = "WB0x"
        case wb15 = "WB1x"
        case wba6 = "WBA6x"
        case wba2 = "WBA2x"
        case st67w6x = "ST67W6x"

        var id: Self { self }

        var boardType: WbBoardType {
            switch self {
            case .wba5: .wba5
            case .wb55: .wb55
            case .wb09: .wb09
            case .wb15: .wb15
            case .wba6: .wba6
            case .wba2: .wba2
            case .st67w6x: .st67w6x
            }
        }

        var secondarySegmentTitle: String {
            switch self {
            case .wba5, .wb09, .wba6, .wba2: "User conf"
            case .st67w6x: "Network"
            case .wb55, .wb15: "Radio"
            }
        }
    }

    enum UpgradeState: Equatable {
        case idle
        case upgrading(progress: Double)
        case succeeded
    }

    struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    let node: Node
    let firmware: Firmware?
    let isMandatory: Bool
    let completion: ((Bool) -> Void)?

    @Published private(set) var boardName = "-"
    @Published private(set) var boardVersion = "-"
    @Published private(set) var mcuType = "-"
    @Published private(set) var isSTM32 = false
    @Published var board: Board
    @Published var installsApplication = true
    @Published var selectedFileURL: URL?
    @Published var isFileImporterPresented = false
    @Published private(set) var upgradeState: UpgradeState = .idle
    @Published var alertInfo: AlertInfo?

    init(configuration: SUIFirmwareSelect) {
        node = configuration.node
        firmware = configuration.firmware
        isMandatory = configuration.isMandatory
        completion = configuration.completion
        board = Self.defaultBoard(for: configuration.node)
    }

    var firmwareType: FirmwareType {
        guard isSTM32 else {
            return .application(board: .other)
        }
        return installsApplication ? .application(board: board.boardType) : .radio(board: board.boardType)
    }

    var selectedFirmwareName: String {
        selectedFileURL?.lastPathComponent ?? firmware?.compoundName ?? Localizer.Firmware.Action.select.localized
    }

    var isUpgrading: Bool {
        if case .upgrading = upgradeState { return true }
        return false
    }

    func load() {
        isSTM32 = BlueManager.shared.firmwareServiceType(for: node) == .stm32

        guard let catalogService: CatalogService = Resolver.shared.resolve() else { return }
        BlueManager.shared.firmwareCurrentVersion(for: node, catalog: catalogService.catalog) { [weak self] version in
            Task { @MainActor in
                self?.boardName = version?.name ?? "-"
                self?.boardVersion = version?.stringValue ?? "-"
                self?.mcuType = version?.mcuType ?? "-"
            }
        }
    }

    func selectFile(_ result: Swift.Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.pathExtension.lowercased() == "bin" else {
                alertInfo = AlertInfo(title: Localizer.Common.warning.localized, message: "Please select a .bin firmware file.")
                return
            }
            selectedFileURL = url
        case .failure(let error):
            guard (error as NSError).code != NSUserCancelledError else { return }
            alertInfo = AlertInfo(title: Localizer.Common.warning.localized, message: error.localizedDescription)
        }
    }

    func upgrade() {
        guard !isUpgrading else { return }

        if let selectedFileURL {
            installFirmware(at: selectedFileURL)
        } else {
            downloadAndInstallFirmware()
        }
    }

    private func downloadAndInstallFirmware() {
        guard let firmware else {
            alertInfo = AlertInfo(title: Localizer.Common.warning.localized, message: "Select a firmware file before upgrading.")
            return
        }

        upgradeState = .upgrading(progress: 0)
        URLSession.shared.directDownloadFirmware(firmware) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let url):
                    self.installFirmware(at: url)
                case .failure(let error):
                    self.upgradeState = .idle
                    self.alertInfo = AlertInfo(title: Localizer.Common.warning.localized, message: "Corrupted file")
                    Logger.debug(text: error.localizedDescription)
                }
            }
        }
    }

    private func installFirmware(at url: URL) {
        guard let catalogService: CatalogService = Resolver.shared.resolve(), let catalog = catalogService.catalog else {
            upgradeState = .idle
            alertInfo = AlertInfo(title: Localizer.Common.warning.localized, message: "Firmware catalog is unavailable.")
            return
        }

        let needsSecurityScopedAccess = url.startAccessingSecurityScopedResource()
        upgradeState = .upgrading(progress: 0)

        BlueManager.shared.firmwareUpgrade(
            for: node,
            type: firmwareType,
            url: url,
            catalog: catalog,
            callback: DefaultFirmwareUpgradeCallback(
                completion: { [weak self] _, error in
                    if needsSecurityScopedAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                    Task { @MainActor in
                        guard let self else { return }
                        if let error {
                            self.upgradeState = .idle
                            self.alertInfo = AlertInfo(title: Localizer.Common.warning.localized, message: error.localizedDescription)
                            Logger.debug(text: "[Firmware upgrade] Fail with error: \(error.localizedDescription)")
                        } else {
                            self.upgradeState = .succeeded
                            self.completion?(true)
                            Logger.debug(text: "[Firmware upgrade] Complete with success")
                        }
                    }
                },
                progress: { [weak self] _, bytes, totalBytes in
                    let progress = totalBytes > 0 ? Double(bytes) / Double(totalBytes) : 0
                    Task { @MainActor in
                        self?.upgradeState = .upgrading(progress: progress)
                    }
                }
            )
        )
    }

    private static func defaultBoard(for node: Node) -> Board {
        if node.type == .nucleoWB0X { return .wb09 }
        if node.type == .wba65RiNucleoBoard || node.type == .stm32wba65iDk1Board { return .wba6 }
        if node.type == .st67w6x { return .st67w6x }
        if node.type == .wba2NucleoBoard { return .wba2 }
        if node.type.family == .wbaFamily { return .wba5 }
        return .wb55
    }
}
