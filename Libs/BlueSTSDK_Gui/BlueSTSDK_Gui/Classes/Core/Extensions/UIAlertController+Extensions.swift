//
//  UIAlertController+Extensions.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 28/01/21.
//

import UIKit

public extension UIAlertController {
    static func presentActionSheet(from viewController: UIViewController, title: String?, message: String? = nil, actions: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { controller.addAction($0) }
        
        viewController.present(controller, animated: true)
    }
    
    static func presentAlert(from viewController: UIViewController, title: String?, message: String? = nil, actions: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { controller.addAction($0) }
        
        viewController.present(controller, animated: true)
    }
    
    static func presentAlert(from viewController: UIViewController, title: String?, message: String? = nil, confirmButton: UIAlertAction) {
        presentAlert(from: viewController, title: title, message: message, actions: [confirmButton])
    }
    
    static func presentAlert(from viewController: UIViewController, title: String?, message: String? = nil, confirmButton: UIAlertAction, cancelButton: UIAlertAction = UIAlertAction.cancelButton()) {
        presentAlert(from: viewController, title: title, message: message, actions: [confirmButton, cancelButton])
    }
    
    static func presentTextFieldAlert(from viewController: UIViewController,
                                      title: String?,
                                      message: String? = nil,
                                      confirmButton: UIAlertAction,
                                      cancelButton: UIAlertAction = UIAlertAction.cancelButton(),
                                      textFieldConfiguration: @escaping (UITextField, UIAlertController) -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addTextField { textField in
            textFieldConfiguration(textField, controller)
        }
        
        controller.addAction(confirmButton)
        controller.addAction(cancelButton)
        
        viewController.present(controller, animated: true)
    }
}

public extension UIAlertAction {
    static func genericButton(_ title: String = "Ok".localizedFromGUI, _ action: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: title, style: .default, handler: action)
    }
    
    static func destructiveButton(_ title: String = "Ok".localizedFromGUI, _ action: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: title, style: .destructive, handler: action)
    }
    
    static func cancelButton(_ title: String = "Cancel".localizedFromGUI, _ action: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: title, style: .cancel, handler: action)
    }
}
