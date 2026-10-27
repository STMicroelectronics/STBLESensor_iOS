//
//  ModalService.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

enum ModalService {
    
    static func showAlert(with title: String?,
                          message: String?,
                          okTitle: String?,
                          cancelTitle: String?,
                          completion: ((Bool) -> Void)?) {
        
        guard let controller = UIApplication.shared.visibleTopViewController() else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if okTitle != nil {
            let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
                if let block = completion {
                    block(true)
                }
            }
            
            alert.addAction(okAction)
        }
        
        if cancelTitle != nil {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                if let block = completion {
                    block(false)
                }
            }
            
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true)
        }
    }
    
    static func showMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "SensorTile.box",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: nil,
                  completion: completion)
    }
    
    static func showWarningMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "Warning",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: nil,
                  completion: completion)
    }
    
    static func showConfirm(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "Warning",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: "Cancel",
                  completion: completion)
    }
    
    static func showUploadMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "Upload",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: nil,
                  completion: completion)
    }
    
}

private extension UIApplication {
    func visibleTopViewController() -> UIViewController? {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow })

        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }

        return rootViewController.topMostViewController()
    }
}

private extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
        }

        if let presentedViewController {
            return presentedViewController.topMostViewController()
        }

        return self
    }
}

