//
//  Bundle+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 10/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

extension Bundle {
    static func current() -> Bundle {
        let myBundle = Bundle(for: BaseViewController.self)
        
        guard let resourceBundleURL = myBundle.url(forResource: "STTrilobyte", withExtension: "bundle") else {
            fatalError("Bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access bundle!")
        }
        
        return resourceBundle
    }
}
