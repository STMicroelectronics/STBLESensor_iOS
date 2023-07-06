//
//  AppDelegate.swift
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
import STCore
import STBlueSDK
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        NavigationLayout.base.applyTo(navBar: nil,
                                      navItem: nil)

        configureResolver()

        StandardHUD.shared.configure()

        IQKeyboardManager.shared.enable = true

        window = UIWindow(frame: UIScreen.main.bounds)

        if let sessionService: SessionService = Resolver.shared.resolve(),
           sessionService.isWelcomeNeeded {
            goToWelcome()
        } else {
            window?.rootViewController = MainPresenter().start()
        }

        var currentEnv = Environment.prod
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            currentEnv = .dev
        }

        BlueManager.shared.updateCatalog(with: currentEnv) { catalog, error in
            if let error = error {
                Logger.debug(text: error.localizedDescription)
            } else if let catalog = catalog {
                Logger.debug(text: "Catalog version: \(catalog.version ?? "0"), cheksum: \(catalog.checksum ?? "")")
            }
        }

        window?.makeKeyAndVisible()

        return true
    }
}
