//
//  AppInfoView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

struct AppInfoView: View {

    @StateObject private var viewModel = AppInfoViewModel()

    var body: some View {
        VStack(spacing: 16) {

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text(viewModel.appName)
                .font(.largeTitle)
                .multilineTextAlignment(.center)

            Text(viewModel.version)
                .font(.title)

            Text(viewModel.build)
                .font(.body)
                .onTapGesture {
                    viewModel.buildTapped()
                }

            Spacer()
        }
        .padding()
        .navigationTitle("Application Info")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Alert
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {

            if viewModel.selectedEnv != nil {
                Button("ACTIVATE") {
                    viewModel.activateCatalog()
                }

                Button("CANCEL", role: .destructive) {}
            } else {
                Button("OK", role: .cancel) {}
            }

        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
