//
//  SUIFirmwareSelectView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import STUI
import STCore

public struct SUIFirmwareSelectView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SUIFirmwareSelectViewModel

    private let onFinished: () -> Void

    public init(configuration: SUIFirmwareSelect, onFinished: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: SUIFirmwareSelectViewModel(configuration: configuration))
        self.onFinished = onFinished
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                boardInformation

                if viewModel.isSTM32 {
                    stm32TypeSelector
                }

                firmwareSelection
                upgradeButton
            }
            .padding(20)
        }
        .navigationTitle(Localizer.Firmware.Text.title.localized)
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isUpgrading)
        .overlay {
            if viewModel.isUpgrading {
                upgradeProgressOverlay
            }
        }
        .fileImporter(
            isPresented: $viewModel.isFileImporterPresented,
            allowedContentTypes: [UTType(filenameExtension: "bin") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            viewModel.selectFile(result)
        }
        .tint(SUIColorLayout.primary.color)
        .alert(item: $viewModel.alertInfo) { info in
            Alert(
                title: Text(info.title),
                message: Text(info.message),
                dismissButton: .default(Text(Localizer.Common.ok.localized))
            )
        }
        .onChange(of: viewModel.upgradeState) { _, state in
            guard state == .succeeded else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                onFinished()
                dismiss()
            }
        }
        .task { viewModel.load() }
    }

    private var boardInformation: some View {
        VStack(alignment: .leading, spacing: 10) {
            infoRow(title: "Name:", value: viewModel.boardName)
            infoRow(title: "Version:", value: viewModel.boardVersion)
            infoRow(title: "MCU Type:", value: viewModel.mcuType)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }

    private var stm32TypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Firmware type")
                .font(.headline)

            SwiftUI.Picker("Board type", selection: $viewModel.board) {
                ForEach(SUIFirmwareSelectViewModel.Board.allCases) { board in
                    Text(board.rawValue).tag(board)
                }
            }
            .pickerStyle(.menu)

            SwiftUI.Picker("Firmware area", selection: $viewModel.installsApplication) {
                Text("Application").tag(true)
                Text(viewModel.board.secondarySegmentTitle).tag(false)
            }
            .pickerStyle(.segmented)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }

    private var firmwareSelection: some View {
        HStack(spacing: 10) {
            Text(viewModel.selectedFirmwareName)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.isMandatory {
                Button {
                    viewModel.isFileImporterPresented = true
                } label: {
                    Image(systemName: "folder")
                        .frame(width: 40, height: 40)
                }
                .accessibilityLabel(Localizer.Firmware.Action.select.localized)
            }
        }
        .padding(.horizontal, 20)
    }

    private var upgradeButton: some View {
        Button(Localizer.Firmware.Action.upgrade.localized) {
            viewModel.upgrade()
        }
        .applyButtonLayout(.standard.with(fullWidth: true))
        .padding(.top, 20)
    }

    private var upgradeProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Upgrading…")
                    .font(.headline)

                if case .upgrading(let progress) = viewModel.upgradeState {
                    ProgressView(value: progress)
                        .tint(SUIColorLayout.primary.color)
                    Text("\(Int(progress * 100))% Complete")
                        .font(.caption)
                }
            }
            .padding(24)
            .frame(maxWidth: 260)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title).font(.subheadline)
            Text(value).font(.subheadline)
        }
    }
}
