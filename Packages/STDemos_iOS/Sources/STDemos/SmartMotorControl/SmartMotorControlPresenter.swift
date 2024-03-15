//
//  SmartMotorControlPresenter.swift
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

final class SmartMotorControlPresenter: DemoPresenter<TabBarViewController> {

    var leftController: UIViewController?
    var rightController: UIViewController?

    weak var currentController: UIViewController?

    override func viewWillAppear() {

    }

    override func viewWillDisappear() {

    }
}

// MARK: - HSDDelegate
extension SmartMotorControlPresenter: TabBarDelegate {

    func load() {

        view.configureView()

//        view.title = Demo.smartMotorControl.title
//        demoFeatures = param.node.characteristics.features(with: Demo.smartMotorControl.features)

        if let dtmi = BlueManager.shared.dtmi(for: param.node) {

            let leftPresenter = HSDPnpLPresenter(type: .highSpeedDataLog,
                                                 param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                 param: dtmi.contents.sensors))
            leftController = leftPresenter.start()

            let rightPresenter: MotorControlPresenter = MotorControlPresenter(param: param.node)
            rightController = rightPresenter.start()

//            rightPresenter.viewWillAppear()

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

                leftController.stTabBarView?.add(
                    TabBarItem(
                        with: "Sensors/Actuators",
                        image: ImageLayout.image(with: "smart_motor_control_sensors", in: .module),
                        callback: { [weak self]_ in
                            guard let self else { return }
                            
                            if self.currentController === self.leftController {
                                return
                            } else {
                                self.rightController?.remove()
                                
                                self.currentController = leftController
                                self.view.title = "Sensors/Actuators"
                                self.view.add(leftController)
                            }
                        }
                    ), side: .first
                )

                leftController.stTabBarView?.add(
                    TabBarItem(
                        with: "Motor Control",
                        image: ImageLayout.image(with: "smart_motor_control_icon", in: .module),
                        callback: { [weak self] _ in
                            guard let self else { return }
                            
                            if self.currentController === self.rightController {
                                return
                            } else if let rightController = self.rightController {
                                leftController.remove()
                                
                                self.currentController = rightController
                                self.view.title = "Motor Control"
                                self.view.add(rightController)
                            }
                }), side: .second)

                leftController.stTabBarView?.setMainAction { _ in
                    leftPresenter.logStartStop()
                }
            }
        }
    }
}
