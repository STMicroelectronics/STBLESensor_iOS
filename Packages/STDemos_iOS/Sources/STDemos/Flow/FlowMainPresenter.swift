//
//  FlowPresenter.swift
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

final class FlowMainPresenter: DemoPresenter<TabBarViewController> {
    
    var flowController: UIViewController?
    var controlController: UIViewController?
    var sensorsController: UIViewController?
    var moreController: UIViewController?

    weak var currentController: UIViewController?

    override func viewWillAppear() {

    }

    override func viewWillDisappear() {

    }
}

// MARK: - FlowViewControllerDelegate
extension FlowMainPresenter: TabBarDelegate {

    func load() {
        
        view.configureView()
        
        var controllerTabSide: [TabBarSide] = [.first, .second, .third, .fourth]
        
        let flowPresenter: FlowTabPresenter = FlowTabPresenter(param: param.node)
        flowController = flowPresenter.start()
        
        let sensorPresenter: SensorsTabPresenter = SensorsTabPresenter(param: param.node)
        sensorsController = sensorPresenter.start()
        
        let morePresenter: FlowMoreTabPresenter = FlowMoreTabPresenter(param: param.node)
        moreController = morePresenter.start()
        
        currentController = flowController

        if let flowController = flowController {
            flowController.view.translatesAutoresizingMaskIntoConstraints = false

            view.addChild(flowController)
            view.mainView.childContainerView.addSubview(flowController.view, constraints: UIView.fitToSuperViewConstraints)
            view.title = "Flow"
            flowController.didMove(toParent: view)

            flowController.stTabBarView?.showArcActionButton = false
            flowController.stTabBarView?.showFourthTab = false
            flowController.stTabBarView?.layoutSubviews()
            
            flowController.stTabBarView?.add(
                TabBarItem(
                    with: "Flow",
                    image: ImageLayout.image(with: "flow_tab_icon", in: .module),
                    callback: { [weak self]_ in
                        
                        guard let self else { return }
                        
                        if self.currentController === self.flowController {
                            return
                        } else {
                            self.sensorsController?.remove()
                            self.moreController?.remove()
                            
                            self.currentController = flowController
                            self.view.title = "Flow"
                            self.view.add(flowController)
                        }
                    }
                ), side: controllerTabSide[0]
            )
            
            if let dtmi = BlueManager.shared.dtmi(for: param.node) {
                let controlTabPresenter = FlowControlTabPresenter(
                    type: .standard,
                    param: DemoParam<[PnpLContent]>(
                        node: param.node,
                        param: dtmi.contents)
                )
                controlController = controlTabPresenter.start()
                
                flowController.stTabBarView?.showFourthTab = true
                
                flowController.stTabBarView?.add(
                    TabBarItem(
                        with: "Control",
                        image: ImageLayout.image(with: "demo_pnpl", in: STUI.bundle)?.maskWithColor(color: ColorLayout.systemWhite.light),
                        callback: { [weak self] _ in
                            
                            guard let self else { return }
                            
                            if self.currentController === self.sensorsController {
                                return
                            } else if let controlController = self.controlController {
                                self.controlController?.remove()
                                self.controlController?.remove()
                                
                                self.currentController = controlController
                                self.view.title = "Control"
                                self.view.add(controlController)
                            }
                        }
                    ), side: controllerTabSide[1]
                )
            } else {
                controllerTabSide = [.first, .first, .second, .third]
            }
            
            flowController.stTabBarView?.add(
                TabBarItem(
                    with: "Sensors",
                    image: ImageLayout.image(with: "flow_sensor_tab_icon", in: .module),
                    callback: { [weak self] _ in
                        
                        guard let self else { return }
                        
                        if self.currentController === self.sensorsController {
                            return
                        } else if let sensorsController = self.sensorsController {
                            self.flowController?.remove()
                            self.moreController?.remove()
                            
                            self.currentController = sensorsController
                            self.view.title = "Sensors"
                            self.view.add(sensorsController)
                        }
                    }
                ), side: controllerTabSide[2]
            )

            flowController.stTabBarView?.add(
                TabBarItem(
                    with: "More",
                    image: ImageLayout.image(with: "flow_more_icon", in: .module),
                    callback: { [weak self] _ in
                        
                        guard let self else { return }
                        
                        if self.currentController === self.moreController {
                            return
                        } else if let moreController = self.moreController {
                            self.flowController?.remove()
                            self.sensorsController?.remove()
                            
                            self.currentController = moreController
                            self.view.title = "More"
                            self.view.add(moreController)
                        }
                    }
                ), side: controllerTabSide[3]
            )
        }
    }
}
