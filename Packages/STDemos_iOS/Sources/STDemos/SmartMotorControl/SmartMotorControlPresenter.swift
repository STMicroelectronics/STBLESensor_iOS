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

    var isRunningLog: Bool = false
    var isRunningMotor: Bool = false
    
    var hsdController: UIViewController?
    var tagController: UIViewController?
    var mcController: UIViewController?
    
    var mcTabBarItem: TabBarItem?
    var hsdTabBarItem: TabBarItem?
    var tagTabBarItem: TabBarItem?

    weak var currentController: UIViewController?

    override func viewWillAppear() {

    }

    override func viewWillDisappear() {

    }
}

// MARK: - HSDDelegate
extension SmartMotorControlPresenter: TabBarDelegate, HSDLogIsRunningDelegate, MotorControlIsRunningDelegate {
    func isMotorRunning(isRunning: Bool) {
        isRunningMotor = isRunning
    }
    
    func isLogRunning(isRunning: Bool) {
        isRunningLog = isRunning
        updateTabBar()
    }

    func load() {

        demoFeatures = param.node.characteristics.features(with: Demo.smartMotorControl.features)
        
        view.configureView()
        
        if let dtmi = BlueManager.shared.dtmi(for: param.node) {
            
            let hsdPresenter = HSDMotorControlPresenter(type: .highSpeedDataLog,
                                                 param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                 showTabBar: true,
                                                                                 param: dtmi.contents.motorControl))
            hsdPresenter.delegate = self
            hsdController = hsdPresenter.start()
            
            let tagPresenter = HSDPnpLTagPresenter(type: .highSpeedDataLog,
                                                   param: DemoParam<[PnpLContent]>(node: param.node,
                                                                                   showTabBar: true,
                                                                                   param: dtmi.contents.settingsNotLogging))
            tagController = tagPresenter.start()
            
            let mcPresenter: MotorControlPresenter = MotorControlPresenter(param: DemoParam<Void>(node: param.node, showTabBar: true))
            mcController = mcPresenter.start()
            mcPresenter.view.motorDelegate = self

            hsdPresenter.viewWillAppear()
            if let hsdController = hsdController as? BlueDelegate {
                BlueManager.shared.addDelegate(hsdController)
            }
            
//            tagPresenter.viewWillAppear()
            if let tagController = tagController as? BlueDelegate {
                BlueManager.shared.addDelegate(tagController)
            }

            currentController = mcController

            if let mcController = mcController {
                if let hsdController = hsdController {
                    if let tagController = tagController {
                        
                        tagController.view.translatesAutoresizingMaskIntoConstraints = false
                        view.addChild(tagController)
                        view.mainView.childContainerView.addSubview(tagController.view, constraints: UIView.fitToSuperViewConstraints)
                        view.title = "Tag"
                        hsdController.didMove(toParent: view)
                        
                        hsdController.view.translatesAutoresizingMaskIntoConstraints = false
                        view.addChild(hsdController)
                        view.mainView.childContainerView.addSubview(hsdController.view, constraints: UIView.fitToSuperViewConstraints)
                        view.title = "Configuration"
                        hsdController.didMove(toParent: view)
                        
                        mcController.view.translatesAutoresizingMaskIntoConstraints = false
                        view.addChild(mcController)
                        view.mainView.childContainerView.addSubview(mcController.view, constraints: UIView.fitToSuperViewConstraints)
                        view.title = "Motor Control"
                        mcController.didMove(toParent: view)
                        
                        mcTabBarItem = TabBarItem(
                            with: "Motor Control",
                            image: ImageLayout.image(with: "smart_motor_control_icon", in: .module),
                            callback: { [weak self]_ in
                                guard let self else { return }
                                
                                if self.currentController === self.mcController {
                                    return
                                } else {
                                    self.hsdController?.remove()
                                    self.tagController?.remove()
                                    
                                    self.currentController = mcController
                                    self.view.title = "Motor Control"
                                    self.view.add(mcController)
                                }
                            }
                        )
                        
                        hsdTabBarItem = TabBarItem(
                            with: "Configuration",
                            image: ImageLayout.Common.gearFilled?.original.withTintColor(ColorLayout.systemWhite.light),
                            callback: { [weak self] _ in
                                guard let self else { return }
                                
                                if self.currentController === self.hsdController {
                                    return
                                } else {
//                                    self.mcController?.remove()
                                    self.tagController?.remove()
                                    
                                    self.currentController = hsdController
                                    self.view.title = "Configuration"
                                    self.view.add(hsdController)
                                }
                            }
                        )
                        
                        tagTabBarItem = TabBarItem(
                            with: "Tag",
                            image: ImageLayout.Common.tagFilled?.original.withTintColor(ColorLayout.systemWhite.light),
                            callback: { [weak self] _ in
                                guard let self else { return }
                                
                                if self.currentController === self.tagController {
                                    return
                                } else {
//                                    self.mcController?.remove()
                                    self.hsdController?.remove()
                                    
                                    self.currentController = tagController
                                    self.view.title = "Tag"
                                    self.view.add(tagController)
                                }
                            }
                        )
                        
                        updateTabBar()
                        
                        mcController.stTabBarView?.setMainAction { _ in
                            if self.isRunningMotor && self.isRunningLog {
                                self.showMCSuggestionMessage("Motor is still Running ...\nStop before the motor")
                            } else {
                                hsdPresenter.logStartStop()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showMCSuggestionMessage(_ message: String) {
        self.view.view.makeToast(message, duration: 4.0, position: .center, title: "WARNING")
    }
    
    private func updateTabBar() {
        guard let mcController = mcController else { return }
        
        if let mcTabBarItem = mcTabBarItem {
            if let hsdTabBarItem = hsdTabBarItem {
                if let tagTabBarItem = tagTabBarItem {
                    
                    mcController.stTabBarView?.removeAllTabs()
                    
                    mcController.stTabBarView?.add(mcTabBarItem, side: .first)
                    if isRunningLog {
                        mcController.stTabBarView?.add(tagTabBarItem, side: .second)
                    } else {
                        mcController.stTabBarView?.add(hsdTabBarItem, side: .second)
                    }
                }
            }
        }
    }
}
