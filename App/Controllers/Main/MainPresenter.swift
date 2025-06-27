//
//  MainPresenter.swift
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
import AppTrackingTransparency

final class MainPresenter: VoidPresenter<TabBarViewController> {

}

// MARK: - MainViewControllerDelegate
extension MainPresenter: TabBarDelegate {

    func load() {
        view.configureView()

        let controller = NodeListPresenter().start().embeddedInNav()
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        view.addChild(controller)
        view.mainView.childContainerView.addSubview(controller.view, constraints: UIView.fitToSuperViewConstraints)

        requestAppTrackingTransparencyPermission()
        
        showPinForNode()
    }

    func requestAppTrackingTransparencyPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Authorized")
                    /** START EtnaAnalytics - [Basic Analytics] */
                    if let analytics: AnalyticsService = Resolver.shared.resolve() {
                        analytics.etnaBasicAnalytics()
                        analytics.etnaUserProfileAnalytics()
                    }
                case .denied:
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }

    func showPinForNode() {
        guard let store: GenericBleNodePinService = Resolver.shared.resolve() else { return }

        let dialogTitle = "DEFAULT PIN"
        let dialogMessage =
        """
        The default PIN to establish a Bluetooth connection with the STMicroelectronics evaluation board is 123456.

        By clicking the 'OK' button, you confirm that you have read and understood this information.
        """

        if !store.isDialogShowed() {
            Alert.show(title: dialogTitle,
                       message: dialogMessage,
                       from: self.view, completion: { _ in
                store.setDialogShowed()
                print("CLICCATO OK")
            })
        }
    }
}
