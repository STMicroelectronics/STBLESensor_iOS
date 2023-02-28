//
//  UINavigationController+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 16/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func popToController<T: UIViewController>(_ type: T.Type, animated: Bool) {
        if let controller = viewControllers.first(where: { $0 is T }) {
            popToViewController(controller, animated: animated)
        }
    }
    func popToControllerOrToRootControllerIfNotInTheStack<T: UIViewController>(_ type: T.Type, animated: Bool) {
        if let controller = viewControllers.first(where: { $0 is T }) {
            popToViewController(controller, animated: animated)
        } else {
            popToRootViewController(animated: animated)
        }
    }
    
}
