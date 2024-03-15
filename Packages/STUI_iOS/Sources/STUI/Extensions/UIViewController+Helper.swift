//
//  UIViewController+Helper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import SafariServices
import STCore

public extension UIViewController {

    var stTabBarView: TabBarView? {
        if let controller = parent as? TabBarViewController {
            return controller.mainView.tabBarView
        } else if let controller = parent?.parent as? TabBarViewController {
            return controller.mainView.tabBarView
        }

        return nil
    }

    func embeddedInNav() -> UINavigationController {
        UINavigationController(rootViewController: self)
    }

    static func make<T>() -> T? where T: UIViewController {
        guard let view: T = self.viewControllerFromNib() else {
            return nil
        }

        return view
    }

    private static func viewControllerFromNib<T>() -> T? where T: UIViewController {
        let bundle = Bundle(for: self)

        return T(nibName: String(describing: self), bundle: bundle)
    }

    func open(url: String, presentationStyle: UIModalPresentationStyle = .fullScreen) {
        guard let url = URL(string: url) else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = presentationStyle
        
        self.present(safariViewController, animated: true)
    }

//    static func findFinalPresented(from viewController: UIViewController) -> UIViewController {
//        if let presented = viewController.presentedViewController, !(presented is SFSafariViewController) {
//            return findFinalPresented(from: presented)
//        }
//
//        return viewController
//    }

    static func findLastViewController(from viewController: UIViewController) -> UIViewController {
        if let nvc = viewController as? UINavigationController {
            return nvc.visibleViewController ?? viewController
        }

        return viewController
    }

    var lastViewController: UIViewController? {
        if let nvc = self as? UINavigationController {
            return nvc.visibleViewController
        }

        if let pvc = self.presentedViewController {
            return pvc
        }

        return self
    }

    var topMostViewController: UIViewController? {

        if let tbc = self as? TabBarViewController {
            if let selected = tbc.children.first {
                return selected.topMostViewController
            }
        }

        if let tbc = self as? UITabBarController {
            if let selected = tbc.selectedViewController {
                return selected.topMostViewController
            }
        }

        if let nvc = self as? UINavigationController {
            return nvc.lastViewController
        }

        return self
    }

    var leafViewController: UIViewController? {
        if let tbc = self as? UITabBarController {
            if let selected = tbc.selectedViewController {
                return UIViewController.findLastViewController(from: selected)
            }
        }

        return UIViewController.findLastViewController(from: self)
    }

    func show(error: STError, confirm: String, cancel: String?, completion: @escaping AlertBoolCompletion) {
        if let cancel = cancel {
            Alert.ask(message: error.localizedDescription,
                      okText: confirm,
                      cancelText: cancel,
                      from: self,
                      completion: completion)
        } else {
            Alert.show(message: error.localizedDescription,
                       from: self)
        }
    }

}
