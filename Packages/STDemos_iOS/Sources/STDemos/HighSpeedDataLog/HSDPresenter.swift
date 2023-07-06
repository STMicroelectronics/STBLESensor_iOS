//
//  HSDPresenter.swift
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

final class HSDPresenter: DemoPresenter<TabBarViewController> {

    var leftController: UIViewController?
    var rightController: UIViewController?

    weak var currentController: UIViewController?

    override func viewWillAppear() {

    }

    override func viewWillDisappear() {

    }
}

// MARK: - HSDDelegate
extension HSDPresenter: TabBarDelegate {

    func load() {

        view.configureView()

        view.title = Demo.highSpeedDataLog.title
        demoFeatures = param.node.characteristics.features(with: Demo.highSpeedDataLog.features)

        if let dtmi = BlueManager.shared.dtmi(for: param.node) {

            let leftPresenter = HSDPnpLPresenter(type: .highSpeedDataLog,
                                                 param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                 param: dtmi.contents.sensors))
            leftController = leftPresenter.start()

            let rightPresenter: HSDPnpLTagPresenter = HSDPnpLTagPresenter(type: .highSpeedDataLog,
                                                                          param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                                          param: dtmi.contents.settingsNotLogging))
            rightController = rightPresenter.start()

            rightPresenter.viewWillAppear()

            if let rightController = rightController as? BlueDelegate {
                BlueManager.shared.addDelegate(rightController)
            }

            currentController = leftController

            if let leftController = leftController {
                leftController.view.translatesAutoresizingMaskIntoConstraints = false

                view.addChild(leftController)
                view.mainView.childContainerView.addSubview(leftController.view, constraints: UIView.fitToSuperViewConstraints)
                view.title = "Sensors"
                leftController.didMove(toParent: view)

                leftController.stTabBarView?.add(TabBarItem(with: "Sensors",
                                             image: ImageLayout.Common.gear?.template,
                                             callback: { [weak self]_ in

                    guard let self else { return }

                    if self.currentController === self.leftController {
                        return
                    } else {
                        self.rightController?.remove()

                        self.currentController = leftController
                        self.view.title = "Sensors"
                        self.view.add(leftController)
                    }

                }), side: .left)

                leftController.stTabBarView?.add(TabBarItem(with: "Tags",
                                             image: ImageLayout.Common.info?.template,
                                             callback: { [weak self] _ in
                    guard let self else { return }

                    if self.currentController === self.rightController {
                        return
                    } else if let rightController = self.rightController {

                        leftController.remove()

                        self.currentController = rightController
                        self.view.title = "Tags"
                        self.view.add(rightController)
                    }
                }), side: .right)

                leftController.stTabBarView?.setMainAction { _ in
                    leftPresenter.logStartStop()
                }
            }
        }
    }

}

public extension TabBarViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        mainView.childContainerView.addSubview(child.view, constraints: UIView.fitToSuperViewConstraints)
        child.didMove(toParent: self)
    }
}

public extension UIViewController {
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
