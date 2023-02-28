//
//  UIViewController+Create.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 21/12/2018.
//  Copyright © 2018 Codermine. All rights reserved.
//

import Foundation

public extension UIViewController {
    
    func embeddedInNav() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    static func makeViewControllerFromNib<T>() -> T where T: UIViewController {
        guard let view: T = self.viewControllerFromNib() else {
            fatalError("Not a valid view type!!")
        }
        
        return view
    }
    
    private static func viewControllerFromNib<T>() -> T? where T: UIViewController {
        let bundle = Bundle.current()
        
        return T(nibName: String(describing: self), bundle: bundle)
    }
    
}
