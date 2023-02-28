//
//  UIViewController+Extensions.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 27/01/21.
//

import UIKit

public extension UIViewController
{
    func add(child viewController: UIViewController, appendTo anotherView: UIView? = nil, atIndex index: Int = 0, constraints: [Constraint] = UIView.fitToSuperViewConstraints)
    {
        addChild(viewController)
        let aView: UIView = anotherView ?? view
        aView.insertSubview(viewController.view, at: index, constraints: constraints)
        viewController.didMove(toParent: self)
    }
    
    func removeFromParentController()
    {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

