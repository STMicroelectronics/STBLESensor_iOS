//
//  DemoPresenter.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI
import STCore
import MessageUI

public class DemoParam<T> {
    public var node: Node
    public var showTabBar: Bool
    public var param: T?

    public init(node: Node, showTabBar: Bool = false, param: T? = nil) {
        self.node = node
        self.showTabBar = showTabBar
        self.param = param
    }
}

public enum PNPLDemoType {
    case standard
    case highSpeedDataLog
}

public protocol DemoDelegate: AnyObject {

    var demo: Demo? { get }

    var demoFeatures: [Feature] { get }

    func viewWillAppear()

    func viewWillDisappear()

}

open class DemoPresenter<T: Presentable>: DemoBasePresenter<T, Void> {
}

open class DemoBasePresenter<T: Presentable, M>: BasePresenter<T, DemoParam<M>>, DemoDelegate {

    public var demo: Demo?
    public var disableNotificationOnDisappear : Bool = true

    public var demoFeatures: [Feature] = [Feature]()

    private let mailDelegate = MFMailComposeDelegate {
        BlueManager.shared.featureLogger.clear()
    }

    open func viewWillAppear() {

        BlueManager.shared.enableNotifications(for: param.node, features: demoFeatures)

        if param.showTabBar {
            view.showTabBar()
        } else {
            view.hideTabBar()
        }

        prepareSettingsMenu()

        if let analytics: AnalyticsService = Resolver.shared.resolve(),
           let demo = demo {
            analytics.startDemo(withName: demo.title)
        }

        view.handleAppStateForeground { [weak self] in
            guard let self = self else { return }
            BlueManager.shared.enableNotifications(for: self.param.node, features: self.demoFeatures)
        } background: { [weak self] in
            guard let self = self else { return }
            BlueManager.shared.disableNotifications(for: self.param.node, features: self.demoFeatures)
        }
    }

    open func viewWillDisappear() {

        if disableNotificationOnDisappear {
            BlueManager.shared.disableNotifications(for: param.node, features: demoFeatures)
        }

        if let analytics: AnalyticsService = Resolver.shared.resolve(),
           let demo = demo {
            analytics.stopDemo(withName: demo.title)
        }

        view.cancelAppStateHandlers()
    }

    open override func prepareSettingsMenu() {
        
        settingsButton.image = ImageLayout.Common.gear?.template

        settingActions.removeAll()

        if let demo = demo,
           let contents = BlueManager.shared.dtmi(for: param.node)?.contents.contents(with: demo) {

            self.disableNotificationOnDisappear = false

            self.settingActions.append(SettingsAction(name: "Demo Configuration",
                                                    handler: { [weak self] in
                guard let self else { return }
                self.view.navigationController?.show(Demo.pnpLike.presenter(with: self.param.node,
                                                                            param: PnplDemoConfiguration(contents: contents)).start(), sender: nil)
            }))

        }

//        START / STOP Logging --- TODO: Add Serial Console Here
//        settingActions.append(view.startStopLoggingAction(stopHandler: { [weak self] in
//            let loggedUrls = BlueManager.shared.featureLogger.loggedFile
//
//            if loggedUrls.isEmpty {
//                return
//            }
//
//            if MFMailComposeViewController.canSendMail() {
//                let mail = MFMailComposeViewController()
//                mail.mailComposeDelegate = self?.mailDelegate
//
//                for url in loggedUrls {
//                    if let fileData = try? Data(contentsOf: url) {
//                        mail.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: url.lastPathComponent)
//                    }
//                }
//
//                self?.view.present(mail, animated: true)
//            } else {
//                // show failure alert
//            }
//        }))

       super.prepareSettingsMenu()
    }

}

public class MFMailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate {

    let handler: () -> Void

    public init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    // MARK: MFMailComposeViewControllerDelegate

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil {
            handler()
        }
        controller.dismiss(animated: true)
    }

}
