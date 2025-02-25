//
//  UINavigationController+Helper.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return viewControllers.last
    }

    override open var childForStatusBarHidden: UIViewController? {
        return viewControllers.last
    }

    public func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)

        if let transitionCoord = transitionCoordinator, animated {
            transitionCoord.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)

        if let transitionCoord = transitionCoordinator, animated {
            transitionCoord.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
