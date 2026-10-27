//
//  AppInfoViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK
import STCore

final class AppInfoViewModel: ObservableObject {

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var selectedEnv: CatalogEnvironment?

    private var betaTapCounter = 0

    var appName: String {
        var name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "App"
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            name += " (Beta)"
        }
        return name
    }

    var version: String {
        "v\(STCore.appShortVersion)"
    }

    var build: String {
        "Build \(STCore.appVersion)"
    }

    // MARK: - Secret Tap Combination
    func buildTapped() {
        betaTapCounter += 1

        if betaTapCounter == 5 {
            loadBetaAlert()
            betaTapCounter = 0
        }
    }

    // MARK: - Alert logic
    private func loadBetaAlert() {
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            alertTitle = "PROD Catalog"
            alertMessage = "Do you want to restore PRODUCTION Catalog?"
            selectedEnv = .prod
        } else {
            alertTitle = "BETA Catalog"
            alertMessage = "Do you want to use BETA Catalog? This may create issues."
            selectedEnv = .dev
        }

        showAlert = true
    }

    func activateCatalog() {
        guard let env = selectedEnv else { return }

        BlueManager.shared.updateCatalog(with: env) { catalog, error in
            DispatchQueue.main.async {
                if let error {
                    self.alertTitle = "ERROR"
                    self.alertMessage = error.localizedDescription
                } else if catalog != nil {
                    let isBeta = (env == .dev)
                    UserDefaults.standard.set(isBeta, forKey: "isBetaCatalogActivated")

                    self.alertTitle = isBeta ? "BETA Catalog" : "PROD Catalog"
                    self.alertMessage = isBeta ?
                        "BETA Catalog Activated" :
                        "Production Catalog Activated"
                }
                self.showAlert = true
            }
        }
    }
}
