//
//  Navigator.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public protocol Navigator {

    @discardableResult
    func start(presenter: Presenter, embeddedNav: Bool) -> UIWindow

    func present(presenter: Presenter, embeddedNav: Bool, modalPresentationStyle: UIModalPresentationStyle, animated: Bool)
    func present(presenter: Presenter, embeddedNav: Bool)
    func present(viewController: UIViewController, animated: Bool)
    func navigate(to presenter: Presenter)
    func navigate(to presenter: Presenter, hidesBottomBarWhenPushed: Bool, animated: Bool)
    func replace(with presenter: Presenter, animated: Bool)

    func dismiss()
    func dismiss(to: Swift.AnyClass)
    
    func dismiss(to: Swift.AnyClass, completion: @escaping () -> Void)
    func dismiss(to: Swift.AnyClass, completion: @escaping (UIViewController?) -> Void)
    func dismiss(animated: Bool)
    
    func dismissToRoot(animated: Bool, completion: @escaping () -> Void)
    func dismissToRoot(animated: Bool, completion: @escaping (UIViewController?) -> Void)

    func dismiss(animated: Bool, completion: @escaping () -> Void)
    func dismiss(animated: Bool, completion: @escaping (UIViewController?) -> Void)

    func open(url: String, presentationStyle: UIModalPresentationStyle)
    func safari(url: String)

    var currentRootViewController: UIViewController? { get }

}
