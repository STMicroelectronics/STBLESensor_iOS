//
//  TrackerThresholdUtilBundle.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class TrackerThresholdUtilBundle {
    public static func bundle() -> Bundle {
        let myBundle = Bundle(for: TrackerThresholdUtilBundle.self)
        
        guard let resourceBundleURL = myBundle.url(forResource: "TrackerThresholdUtilResources", withExtension: "bundle") else {
            fatalError("TrackerThresholdUtilResources.bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access TrackerThresholdUtilResources.bundle!")
        }
        
        return resourceBundle
    }
    
    public static func bundleImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: TrackerThresholdUtilBundle.bundle(), compatibleWith: nil)
    }
}
