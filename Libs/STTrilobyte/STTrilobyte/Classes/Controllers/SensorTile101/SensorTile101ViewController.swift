//
//  SensorTile101ViewController.swift
//  trilobyte-ios
//
//  Created by Stefano Zanetti on 21/12/2018.
//  Copyright © 2018 Codermine. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didUploadFlowsWithStreamOnBleOutput = Notification.Name("didUploadFlowsWithStreamOnBleOutput")
}

public protocol SensorTile101Delegate: class {
    
    func didUploadFlowsWithBleStreamOutput(controller: SensorTile101ViewController)
    
}

public class SensorTile101ViewController: UITabBarController {
    
    public weak var sensorTile101Delegate: SensorTile101Delegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUploadFlowWithStreamOnBleOutput(_:)),
                                               name: .didUploadFlowsWithStreamOnBleOutput,
                                               object: nil)
        
        let sensors: SensorsViewController = SensorsViewController.makeViewControllerFromNib()
        let sensorNc: NavigationController = NavigationController(rootViewController: sensors)
        sensorNc.tabBarItem.title = "navigation_tab_sensors".localized()
        sensorNc.tabBarItem.image = UIImage.named("img_memory")
        
        let flows: CategoriesViewController = CategoriesViewController.makeViewControllerFromNib()
        let flowsNc: NavigationController = NavigationController(rootViewController: flows)
        flowsNc.tabBarItem.title = "navigation_tab_flows".localized()
        flowsNc.tabBarItem.image = UIImage.named("img_start")
        
        let more: MoreViewController = MoreViewController.makeViewControllerFromNib()
        let moreNc: NavigationController = NavigationController(rootViewController: more)
        moreNc.tabBarItem.title = "navigation_tab_more".localized()
        moreNc.tabBarItem.image = UIImage.named("img_menu")
        
        hidesBottomBarWhenPushed = true
        
        setViewControllers([
            flowsNc,
            sensorNc,
            moreNc
        ], animated: false)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let contains = navigationController?.viewControllers.contains(self), contains == false {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension SensorTile101ViewController {
    
    @objc
    func didUploadFlowWithStreamOnBleOutput(_ notification: Notification) {
        guard let sensorTile101Delegate = self.sensorTile101Delegate else { return }
        
        sensorTile101Delegate.didUploadFlowsWithBleStreamOutput(controller: self)
    }
    
}
