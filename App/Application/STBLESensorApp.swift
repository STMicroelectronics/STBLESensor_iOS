//
//  STBLESensorApp.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STCore
import STUI
import STBlueSDK
import IQKeyboardManagerSwift

@main
struct STBLESensorApp: SwiftUI.App {
    init() {
        SUINavigationStyle.applyGlobalAppearance()
        SUINavigationStyle.applyTabBarAppearance()
        StandardHUD.shared.configure()
        IQKeyboardManager.shared.enable = true

        configureResolver()

        updateBlueSDKCatalog()
    }

    var body: some Scene {
        WindowGroup {
            STBLESensorRootView()
        }
    }

    func updateBlueSDKCatalog() {
        var currentEnv = CatalogEnvironment.prod
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            currentEnv = .dev
        }

        BlueManager.shared.updateCatalog(with: currentEnv) { catalog, error in
            if let error = error {
                Logger.debug(text: error.localizedDescription)
            } else if let catalog = catalog {
                Logger.debug(text: "Catalog version: \(catalog.version ?? "0")")
            }
        }
    }
}
