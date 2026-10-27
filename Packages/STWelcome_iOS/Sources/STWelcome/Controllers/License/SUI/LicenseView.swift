//
//  LicenseView.swift
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

struct LicenseView: View {

    @StateObject private var viewModel: LicenseViewModel
    @Environment(\.dismiss) private var dismiss

    init(url: URL) {
        _viewModel = StateObject(
            wrappedValue: LicenseViewModel(url: url)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("License Agreement")
                    .applyTextLayout(.largetitle)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(
                    "Please read carefully the license agreement. " +
                    "If you accept the terms below click 'ACCEPT' otherwise quit the application."
                )
                .font(.system(size: 13, weight: .bold))

                Text(viewModel.licenseText)
                    .font(.system(size: 12, weight: .light))

                Button("ACCEPT") {
                    dismiss()
                }
                .applyButtonLayout(.standard.with(fullWidth: true))
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
    }
}
