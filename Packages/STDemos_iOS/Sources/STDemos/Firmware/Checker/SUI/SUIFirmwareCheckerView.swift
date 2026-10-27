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

import SwiftUI
import STUI
import STCore
import STBlueSDK

// MARK: - View
public struct SUIFirmwareCheckerView: View {

    @StateObject private var viewModel: SUIFirmwareCheckerViewModel

    /// True when this screen is presented modally (vs pushed), mirrors `view.presentingViewController != nil`.
    let isPresentedModally: Bool
    let onCancel: () -> Void
    let onInstall: (Firmware) -> Void

    public init(
        node: Node,
        firmwares: Firmwares,
        completion: ((Bool) -> Void)? = nil,
        isPresentedModally: Bool,
        onCancel: @escaping () -> Void,
        onInstall: @escaping (Firmware) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SUIFirmwareCheckerViewModel(node: node, firmwares: firmwares, completion: completion))
        self.isPresentedModally = isPresentedModally
        self.onCancel = onCancel
        self.onInstall = onInstall
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                firmwareBlock(title: "Current Firmware", value: viewModel.firmwares.current.fullName, valueColor: .primary)

                firmwareBlock(title: viewModel.updateHeadline, value: viewModel.updateFirmware?.fullName ?? "", valueColor: SUIColorLayout.accent.color)

                if viewModel.showsChangelog {
                    firmwareBlock(title: "Changelog", value: viewModel.updateFirmware?.changelog ?? "", valueColor: .primary)
                }

                VStack(spacing: 0) {
                    Divider()
                    Text(viewModel.infoNote)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                    Divider()
                }

                if !viewModel.firmwares.isMandatory {
                    Toggle(isOn: $viewModel.dontAskAgain) {
                        Text("Don't ask me again for this board")
                            .font(.caption)
                    }
                    .tint(SUIColorLayout.primary.color)
                    .toggleStyle(.switch)
                }

                HStack(spacing: 8) {
                    Button("CANCEL") {
                        viewModel.handle(
                            .cancel(dontAskAgain: viewModel.dontAskAgain),
                            isPresentedModally: isPresentedModally,
                            onFinished: onCancel,
                            onInstall: onInstall
                        )
                    }
                    .applyButtonLayout(.standardGray.with(fullWidth: true))

                    Button("INSTALL") {
                        guard let firmware = viewModel.updateFirmware else { return }
                        viewModel.handle(
                            .install(firmware: firmware, dontAskAgain: viewModel.dontAskAgain),
                            isPresentedModally: isPresentedModally,
                            onFinished: onCancel,
                            onInstall: onInstall
                        )
                    }
                    .applyButtonLayout(.standard.with(fullWidth: true))
                    .disabled(viewModel.updateFirmware == nil)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .navigationTitle(Localizer.Firmware.Text.title.localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func firmwareBlock(title: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(value).font(.caption).foregroundStyle(valueColor)
        }
    }
}
