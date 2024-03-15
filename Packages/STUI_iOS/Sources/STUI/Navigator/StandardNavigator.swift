//
//  File.swift
//  
//
//  Created by Stefano Zanetti on 12/06/23.
//

import UIKit
import SafariServices

public final class StandardNavigator: NSObject {
    private let window: UIWindow
    private var currentTransition: UIViewControllerAnimatedTransitioning?

    override public init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        super.init()
    }

    public init(window: UIWindow) {
        self.window = window
        super.init()
    }
}

extension StandardNavigator: Navigator {
    @discardableResult
    public func start(presenter: Presenter, embeddedNav: Bool) -> UIWindow {

        var root = presenter.start()

        if !(root is UITabBarController) && !(root is UINavigationController) && embeddedNav {
            root = root.embeddedInNav()
        }

        let options: UIView.AnimationOptions = [ .transitionCrossDissolve,
                                                 .showHideTransitionViews,
                                                 .layoutSubviews,
                                                 .allowAnimatedContent ]
        UIView.transition(with: window, duration: 0.5, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.window.rootViewController = root
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in

        })

        return window
    }

    // MARK: Presentation & navigation

    public func present(presenter: Presenter, embeddedNav: Bool = false) {
        self.present(presenter: presenter, embeddedNav: embeddedNav, modalPresentationStyle: .automatic, animated: false)
    }

    public func present(presenter: Presenter, embeddedNav: Bool = false, modalPresentationStyle: UIModalPresentationStyle = .automatic, animated: Bool = true) {

        if embeddedNav {
            let controller = presenter.start().embeddedInNav()
            controller.modalPresentationStyle = modalPresentationStyle
            window.rootViewController?.topMostViewController?.present(controller,
                                                                      animated: animated)
        } else {
            let controller = presenter.start().embeddedInNav()
            controller.modalPresentationStyle = modalPresentationStyle
            window.rootViewController?.topMostViewController?.present(controller,
                                                                      animated: animated)
        }
    }

    public func present(viewController: UIViewController, animated: Bool) {
        window.rootViewController?.present(viewController, animated: animated)
    }

    public func navigate(to presenter: Presenter) {
        navigate(to: presenter, hidesBottomBarWhenPushed: false)
    }

    public func navigate(to presenter: Presenter, hidesBottomBarWhenPushed: Bool, animated: Bool = true) {
        go(to: presenter.start(), hidesBottomBarWhenPushed: hidesBottomBarWhenPushed, animated: animated)
    }

    public func replace(with presenter: Presenter, animated: Bool = true) {

        let viewController = presenter.start()

        DispatchQueue.main.async {
            guard let navController = self.currentRootViewController as? UINavigationController else {
                self.currentRootViewController?.present(viewController, animated: animated)
                return
            }

            var controllers = navController.viewControllers
            controllers.removeLast()
            controllers.append(viewController)

            navController.setViewControllers(controllers, animated: animated)
        }
    }

    @objc
    private func close() {
        dismiss(animated: true)
    }

    public func dismiss() {
        dismiss(animated: true)
    }

    public func dismiss(to: Swift.AnyClass) {
        dismiss(toRoot: false, to: to, animated: true) {}
    }

    public func dismiss(animated: Bool) {
        dismiss(animated: animated) {}
    }

    public func dismissToRoot(animated: Bool, completion: @escaping () -> Void) {
        dismiss(toRoot: true, to: nil, animated: animated, completion: completion)
    }

    public func dismiss(animated: Bool, completion: @escaping () -> Void) {
        dismiss(toRoot: false, to: nil, animated: animated, completion: completion)
    }

    public func dismiss(toRoot: Bool = false, to: Swift.AnyClass? = nil, animated: Bool, completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.dismiss(toRoot: toRoot, animated: true, completion: completion)
            }

            return
        }

        guard let viewController = currentRootViewController else { return }


//        if let controller = viewController.topMostViewController {
//            controller.dismiss(animated: animated, completion: completion)
//            return
//        }

        let children = viewController.leafViewController?.children
            .map { $0 as? Childable }
            .compactMap { $0 }.filter { $0.isChild }

        if let children = children {
            if let child = children.last as? UIViewController {
                removeChild(viewController: child)
                completion()
                return
            }
        }

        if viewController.presentingViewController != nil,
           let controller = viewController.topMostViewController {
            controller.dismiss(animated: animated, completion: completion)
            return
        }

        if let nvc = viewController as? UINavigationController {
            if nvc.viewControllers.count > 1 {
                DispatchQueue.main.async {
                    if toRoot {
                        CATransaction.begin()
                        CATransaction.setCompletionBlock {
                            completion()
                        }
                        nvc.popToRootViewController(animated: animated)
                        CATransaction.commit()

                    } else if let to = to {
                        nvc.backToViewController(viewController: to)
                    } else {
                        nvc.popViewController(animated: animated, completion: completion)
                    }
                    return
                }
            } else {
                completion()
                return
            }

            return
        }
    }

    public func open(url: String, presentationStyle: UIModalPresentationStyle) {
        guard let url = URL(string: url) else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = presentationStyle
        self.present(viewController: safariViewController, animated: true)
    }

    public func safari(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }

}

private extension StandardNavigator {
    func go(to viewController: UIViewController, hidesBottomBarWhenPushed: Bool = false, animated: Bool = true) {
        DispatchQueue.main.async {
            guard let navController = self.currentRootViewController as? UINavigationController else {
                self.currentRootViewController?.present(viewController, animated: animated)
                return
            }

            viewController.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
            navController.pushViewController(viewController, animated: animated)
        }
    }
}

public extension StandardNavigator {
    func removeChild(viewController: UIViewController) {
        guard viewController.parent != nil else { return }
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
    }

    func findFinalPresented(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController, !(presented is SFSafariViewController) {
            return findFinalPresented(from: presented)
        }

        return viewController
    }

    var currentRootViewController: UIViewController? {
        if let tbc = window.rootViewController as? UITabBarController {
            if let selected = tbc.selectedViewController {
                return findFinalPresented(from: selected)
            }
        }

        if let tbc = window.rootViewController as? TabBarViewController {
            if let selected = tbc.children.first {
                return findFinalPresented(from: selected)
            }
        }

        if let nvc = window.rootViewController as? UINavigationController {
            return findFinalPresented(from: nvc)
        }

        return window.rootViewController
    }
}

extension StandardNavigator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationController.Operation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return currentTransition
    }
}

extension UINavigationController {

    func backToViewController(viewController: Swift.AnyClass) {
        for element in viewControllers as Array {
            if element.isKind(of: viewController) {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }

}
