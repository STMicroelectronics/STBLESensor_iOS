//
//  File 2.swift
//  
//
//  Created by Stefano Zanetti on 12/06/23.
//

import UIKit

public protocol Navigator {

    @discardableResult
    func start(presenter: Presenter, embeddedNav: Bool) -> UIWindow

    func present(presenter: Presenter, embeddedNav: Bool)
    func present(viewController: UIViewController, animated: Bool)
    func navigate(to presenter: Presenter)
    func navigate(to presenter: Presenter, hidesBottomBarWhenPushed: Bool, animated: Bool)
    func replace(with presenter: Presenter, animated: Bool)

    func dismiss()
    func dismiss(animated: Bool)
    func dismissToRoot(animated: Bool, completion: @escaping () -> Void)
    func dismiss(animated: Bool, completion: @escaping () -> Void)

    func open(url: String, presentationStyle: UIModalPresentationStyle)
    func safari(url: String)

    var currentRootViewController: UIViewController? { get }

}
