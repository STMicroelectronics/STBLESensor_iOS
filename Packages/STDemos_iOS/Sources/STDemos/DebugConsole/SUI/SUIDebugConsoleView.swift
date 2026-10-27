//
//  SUIDebugConsoleView.swift
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

public struct SUIDebugConsoleView: View {

    @StateObject private var viewModel: SUIDebugConsoleViewModel
    @State private var command: String = ""
    @FocusState private var isCommandFieldFocused: Bool

    public init(node: Node) {
        _viewModel = StateObject(wrappedValue: SUIDebugConsoleViewModel(node: node))
    }

    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SwiftUI.TextField("Insert command", text: $command)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 15)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(SUIColorLayout.stGray5.color, lineWidth: 1)
                    )
                    .submitLabel(.done)
                    .focused($isCommandFieldFocused)
                    .onSubmit { isCommandFieldFocused = false }

                Button("SEND") {
                    sendCommand()
                }
                .applyButtonLayout(.standardWithSmallFont)
            }

            ScrollView {
                Text(viewModel.log)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(16)
        .navigationTitle("Debug Console")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendCommand() {
        guard !command.isEmpty else { return }
        viewModel.sendCommand(command)
    }
}
