//
//  BlueSTSDK_Gui.swift
//  BlueSTSDK_Gui
//
//  Created by Klaus Lanzarini on 14/12/20.
//

import Foundation

public class BlueSTSDK_Gui {
    static public func bundle() -> Bundle {
        let myBundle = Bundle(for: Self.self)
        
        guard let resourceBundleURL = myBundle.url(forResource: "BlueSTSDK_Gui", withExtension: "bundle") else {
            fatalError("BlueSTSDK_Gui.bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access BlueSTSDK_Gui.bundle!")
        }
        
        return resourceBundle
    }
}
