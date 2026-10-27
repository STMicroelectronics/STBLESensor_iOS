//
//  FirmwareListView.swift
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

struct FirmwareListView: View {
    @StateObject private var viewModel: FirmwareListViewModel

    init(filter: FirmwareFilter) {
        _viewModel = StateObject(wrappedValue: FirmwareListViewModel(filter: filter))
    }

    var body: some View {
        List(viewModel.firmwares, id: \.fullName) { firmware in
            FirmwareRowView(firmware: firmware)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .onTapGesture {
                    viewModel.didSelect(firmware)
                }
        }
        .listStyle(.plain)
        .navigationTitle(Localizer.CatalogFirmware.Text.title.localized)
        .onAppear {
            viewModel.load()
        }
    }
}
