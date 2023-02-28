//
//  AssetTrackingCloudBundle.swift
//  BundleFactory
//
//  Created by Giovanni Visentini on 06/02/2020.
//  Copyright © 2020 Giovanni Visentini. All rights reserved.
//

import UIKit
import AssetTrackingDataModel

public class AssetTrackingCloudBundle {
    static public func bundle() -> Bundle {
        let myBundle = Bundle(for: AssetTrackingCloudBundle.self)
        
        guard let resourceBundleURL = myBundle.url(forResource: "AssetTrackingCloudDashboardResources", withExtension: "bundle") else {
            fatalError("AssetTrackingCloudDashboardResources.bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access AssetTrackingCloudDashboardResources.bundle!")
        }
        
        return resourceBundle
    }
    
    public static func buildLoginViewController()->UIViewController {
        let storyboard = UIStoryboard(name: "AssetTrackingLogin",
                                      bundle: AssetTrackingCloudBundle.bundle())
        return storyboard.instantiateViewController(withIdentifier: "loginviewcontroller")
        //return storyboard.instantiateInitialViewController()!
    }
    
    public static func buildATRLoginViewController(loginManager: LoginManager)->AssetTrackingLoginViewController {
        let storyboard = UIStoryboard(name: "AssetTrackingLogin",
                                      bundle: AssetTrackingCloudBundle.bundle())
        let loginController = storyboard.instantiateViewController(withIdentifier: "loginviewcontroller") as! AssetTrackingLoginViewController
        loginController.loginManager = loginManager
        return loginController
    }
    
    public static func bundleImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: AssetTrackingCloudBundle.bundle(), compatibleWith: nil)
    }
}
