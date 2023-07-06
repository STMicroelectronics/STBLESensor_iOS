//
//  AppInfoPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STCore

final class AppInfoPresenter: VoidPresenter<AppInfoViewController> {

}

// MARK: - NodeFilterViewControllerDelegate
extension AppInfoPresenter: AppInfoDelegate {

    func load() {
        view.configureView()

    }

    func loadBetaAlert() {
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            showCatalogAlert(
                "PROD Catalog",
                "Do you want to restore PRODUCTION Catalog?.",
                Environment.prod)
        } else {
            showCatalogAlert(
                "BETA Catalog",
                "Do you want to use BETA Catalog? This may create issues in the application.",
                Environment.dev)
        }
    }

    private func showCatalogAlert(_ title: String, _ message: String, _ env: Environment) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ACTIVATE", style: .default, handler: { _ in
            self.updateCatalog(env)
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: .destructive, handler: { _ in
            self.view.dismiss(animated: true)
        }))
        self.view.present(alert, animated: true, completion: nil)
    }

    private func updateCatalog (_ env: Environment) {
        BlueManager.shared.updateCatalog(with: env) { catalog, error in
            if let error = error {
                self.showFeedbackAlert("DECODING ERROR", "\(error.localizedDescription)")
            } else if catalog != nil {
                if env == .dev {
                    UserDefaults.standard.set(true, forKey: "isBetaCatalogActivated")
                    self.showFeedbackAlert("BETA Catalog", "BETA Catalog Activated")
                } else {
                    UserDefaults.standard.set(false, forKey: "isBetaCatalogActivated")
                    self.showFeedbackAlert("PROD Catalog", "Production Catalog Activated")
                }
            }
        }
    }

    private func showFeedbackAlert(_ title: String, _ message: String) {
        UIAlertController.presentAlert(
            from: self.view,
            title: title,
            message: message,
            actions: [
                UIAlertAction.genericButton(Localizer.Common.ok.localized) { _ in }
            ]
        )
    }
}
