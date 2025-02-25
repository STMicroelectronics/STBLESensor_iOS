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

        demo = .highSpeedDataLog2
        
        prepareSettingsMenu()
        
        view.configureView()

        view.title = Demo.highSpeedDataLog.title
        demoFeatures = param.node.characteristics.features(with: Demo.highSpeedDataLog.features)

        if let dtmi = BlueManager.shared.dtmi(for: param.node) {

            let leftPresenter = HSDPnpLPresenter(type: .highSpeedDataLog,
                                                 param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                 showTabBar: true,
                                                                                 param: dtmi.contents.sensors))
            leftController = leftPresenter.start()

            let rightPresenter: HSDPnpLTagPresenter = HSDPnpLTagPresenter(type: .highSpeedDataLog,
                                                                          param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                                          showTabBar: true,
                                                                                                          param: dtmi.contents.settingsNotLogging))
            rightController = rightPresenter.start()

            rightPresenter.viewWillAppear()

//            if let rightController = rightController as? BlueDelegate {
//                BlueManager.shared.addDelegate(rightController)
//            }

            currentController = leftController

            if let leftController = leftController {
                leftController.view.translatesAutoresizingMaskIntoConstraints = false

                view.addChild(leftController)
                view.mainView.childContainerView.addSubview(leftController.view, constraints: UIView.fitToSuperViewConstraints)
                view.title = "Sensors"
                leftController.didMove(toParent: view)

                leftController.stTabBarView?.add(TabBarItem(with: "Sensors",
                                             image: ImageLayout.Common.sensors?.template,
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

                }), side: .first)

                leftController.stTabBarView?.add(TabBarItem(with: "Tags",
                                             image: ImageLayout.Common.tagOutline?.template,
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
                }), side: .second)

                leftController.stTabBarView?.setMainAction { _ in
                    leftPresenter.logStartStop()
                }
                
//                rightController?.stTabBarView?.setMainAction { _ in
//                    rightPresenter.logStartStop()
//                }
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

    func addChildController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view, constraints: UIView.fitToSuperViewConstraints)
        child.didMove(toParent: self)
    }

    func removeChildController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
