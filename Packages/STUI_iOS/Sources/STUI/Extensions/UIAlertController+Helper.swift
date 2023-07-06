//
//  UIAlertController+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STCore

public extension UIAlertController {
    static func presentAlert(from viewController: UIViewController,
                             title: String?,
                             message: String? = nil,
                             style: UIAlertController.Style = .alert,
                             actions: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { controller.addAction($0) }

        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = viewController.view
            ppc.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            ppc.permittedArrowDirections = []
        }

        viewController.present(controller, animated: true)
    }

    static func show(error: STError,
                     from viewController: UIViewController,
                     actions: [UIAlertAction] = [ UIAlertAction.genericButton() ]) {
        let controller = UIAlertController(title: Localizer.Common.warning.localized,
                                           message: error.localizedDescription,
                                           preferredStyle: .alert)
        actions.forEach { controller.addAction($0) }

        viewController.present(controller, animated: true)
    }

    static func warning(message: String,
                        from viewController: UIViewController,
                        actions: [UIAlertAction] = [ UIAlertAction.genericButton() ]) {
        let controller = UIAlertController(title: Localizer.Common.warning.localized,
                                           message: message,
                                           preferredStyle: .alert)
        actions.forEach { controller.addAction($0) }

        viewController.present(controller, animated: true)
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
