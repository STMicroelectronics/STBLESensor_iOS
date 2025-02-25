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
        
        let flowPresenter = FlowTabPresenter(param: DemoParam<Void>(node: param.node,
                                                                    showTabBar: true,
                                                                    param: Void()))
        flowController = flowPresenter.start()
        
        let sensorPresenter = SensorsTabPresenter(param: DemoParam<Void>(node: param.node,
                                                                         showTabBar: true,
                                                                         param: Void()))
        sensorsController = sensorPresenter.start()
        
        let morePresenter = FlowMoreTabPresenter(param: DemoParam<Void>(node: param.node,
                                                                        showTabBar: true,
                                                                        param: Void()))
        moreController = morePresenter.start()
        
        currentController = flowController
        
        var hasControlTab = false

        if let flowController = flowController {
            flowController.view.translatesAutoresizingMaskIntoConstraints = false

            view.addChild(flowController)
            view.mainView.childContainerView.addSubview(flowController.view, constraints: UIView.fitToSuperViewConstraints)
            view.title = "Flow"
            flowController.didMove(toParent: view)

            flowController.stTabBarView?.showArcActionButton = false
            flowController.stTabBarView?.layoutSubviews()
            
            flowController.stTabBarView?.add(TabBarItem(with: "Flow",
                                                        image: ImageLayout.image(with: "flow_tab_icon", in: .module),
                                                        callback: { [weak self]_ in
                guard let self else { return }
                
                if self.currentController === self.flowController {
                    return
                } else {
                    self.controlController?.remove()
                    self.sensorsController?.remove()
                    self.moreController?.remove()
                    
                    self.currentController = flowController
                    self.view.title = "Flow"
                    self.view.add(flowController)
                }
            }), side: .first)
            
            if let dtmi = BlueManager.shared.dtmi(for: param.node) {
                if param.node.hasPnPL {
                    let controlTabPresenter = FlowControlTabPresenter(
                        type: .standard,
                        param: DemoParam<[PnpLContent]>(
                            node: param.node,
                            param: dtmi.contents)
                    )
                    controlController = controlTabPresenter.start()
                    
                    flowController.stTabBarView?.add(TabBarItem(with: "Control",
                                                                image: ImageLayout.image(with: "demo_pnpl", in: STUI.bundle)?.maskWithColor(color: ColorLayout.systemWhite.light),
                                                                callback: { [weak self] _ in
                        guard let self else { return }
                        
                        hasControlTab = true
                        
                        if self.currentController === self.controlController {
                            return
                        } else if let controlController = self.controlController {
                            self.flowController?.remove()
                            self.controlController?.remove()
                            self.moreController?.remove()
                            
                            self.currentController = controlController
                            self.view.title = "Control"
                            self.view.add(controlController)
                        }
                    }), side: .second)
                }
            }
            
            flowController.stTabBarView?.add(TabBarItem(with: "Sensors",
                                                        image: ImageLayout.image(with: "flow_sensor_tab_icon", in: .module),
                                                        callback: { [weak self] _ in
                guard let self else { return }
                
                if self.currentController === self.sensorsController {
                    return
                } else if let sensorsController = self.sensorsController {
                    self.flowController?.remove()
                    self.controlController?.remove()
                    self.moreController?.remove()
                    
                    self.currentController = sensorsController
                    self.view.title = "Sensors"
                    self.view.add(sensorsController)
                }
            }), side: hasControlTab ? .third : .second)

            flowController.stTabBarView?.add(TabBarItem(with: "More",
                                                        image: ImageLayout.image(with: "flow_more_icon", in: .module),
                                                        callback: { [weak self] _ in
                guard let self else { return }
                if self.currentController === self.moreController {
                    return
                } else if let moreController = self.moreController {
                    self.flowController?.remove()
                    self.controlController?.remove()
                    self.sensorsController?.remove()
                    
                    self.currentController = moreController
                    self.view.title = "More"
                    self.view.add(moreController)
                }
            }), side: hasControlTab ? .fourth : .third)
        }
    }
}
