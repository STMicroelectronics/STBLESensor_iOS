//
//  BlueSTSDK_Gui.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BlueSTSDK_Gui {
    static public func bundle() -> Bundle {
        let myBundle = Bundle(for: BlueSTSDK_Gui.self)
        
        guard let resourceBundleURL = myBundle.url(forResource: "BlueSTSDK_GuiResources", withExtension: "bundle") else {
            fatalError("BlueSTSDK_GuiResources.bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access BlueSTSDK_GuiResources.bundle!")
        }
        
        return resourceBundle
    }
    
    public static func bundleImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
    }
}
