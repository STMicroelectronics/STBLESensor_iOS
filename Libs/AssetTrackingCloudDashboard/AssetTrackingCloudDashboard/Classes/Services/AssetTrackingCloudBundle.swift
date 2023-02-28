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
        
        guard let resourceBundleURL = myBundle.url(forResource: "AssetTrackingCloudDashboard", withExtension: "bundle") else {
            fatalError("AssetTrackingCloudDashboard.bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access AssetTrackingCloudDashboard.bundle!")
        }
        
        return resourceBundle
    }
    
    public static func buildLoginViewController()->UIViewController {
        let storyboard = UIStoryboard(name: "AssetTrackingLogin",
                                      bundle: AssetTrackingCloudBundle.bundle())
        return storyboard.instantiateInitialViewController()!
    }
    
    public static func bundleImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: AssetTrackingCloudBundle.bundle(), compatibleWith: nil)
    }
}
