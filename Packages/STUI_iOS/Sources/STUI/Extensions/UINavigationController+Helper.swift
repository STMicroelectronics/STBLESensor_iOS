//
//  UINavigationController+Helper.swift
//  
//
//  Created by Stefano Zanetti on 12/06/23.
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
