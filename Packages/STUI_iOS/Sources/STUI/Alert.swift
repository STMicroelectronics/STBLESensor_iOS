//
//  Alert.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

public typealias AlertCompletion = (String?) -> Void
public typealias AlertBoolCompletion = (Bool) -> Void

import UIKit

public struct AlertActionClosure {
    public let title: String
    public let color: UIColor?
    public let completion: AlertCompletion?
    
    public init(title: String, color: UIColor? = nil, completion: AlertCompletion? = nil) {
        self.title = title
        self.color = color
        self.completion = completion
    }
}

public struct AlertActionClosureBool {
    public let title: String
    public let completion: AlertBoolCompletion
    
    public init(title: String, completion: @escaping AlertBoolCompletion) {
        self.title = title
        self.completion = completion
    }
}

public final class Alert {
    
    static private func alert(title: String,
                              message: String? = nil,
                              placeholder: String? = nil,
                              value: String? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        if placeholder != nil {
            alert.addTextField { textField in
                textField.placeholder = placeholder
                textField.text = value
            }
        }
        
        alert.message = message
        
        return alert
    }
    
    static private func showAlert(title: String,
                                  message: String?,
                                  placeholder: String? = nil,
                                  value: String? = nil,
                                  actions: [AlertActionClosure],
                                  from: UIViewController) {
        let alert = self.alert(title: title, message: message, placeholder: placeholder, value: value)
        
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: .default) { _ in
                guard let completion = action.completion else { return }

                completion(alert.textFields?.first?.text)
            })
        }
        
        from.present(alert, animated: true, completion: nil)
    }
    
}

extension Alert {
    
    static public func show(message: String, from: UIViewController) {
        show(message: message, from: from, completion: nil)
    }
    
    static public func show(message: String, from: UIViewController, completion: AlertCompletion?) {
        show(title: NSLocalizedString("warning", comment: ""), message: message, from: from, completion: completion)
    }
    
    static public func show(title: String, message: String, from: UIViewController) {
        show(title: title, message: message, from: from, completion: nil)
    }
    
    static public func show(title: String, message: String, from: UIViewController, completion: AlertCompletion?) {
        ask(title: title,
            message: message,
            actions: [ AlertActionClosure(title: NSLocalizedString("ok", comment: ""), completion: completion) ],
            from: from)
    }
    
    static public func ask(title: String, message: String, actions: [AlertActionClosure], from: UIViewController) {
        DispatchQueue.main.async {
            self.showAlert(title: title, message: message, actions: actions, from: from)
        }
    }

    static public func ask(title: String,
                           message: String,
                           placeholder: String,
                           value: String?,
                           actions: [AlertActionClosure],
                           from: UIViewController) {
        DispatchQueue.main.async {
            self.showAlert(title: title, message: message, placeholder: placeholder, value: value, actions: actions, from: from)
        }
    }
    
    static public func ask(message: String, from: UIViewController, completion: AlertBoolCompletion?) {
        ask(message: message,
            okText: NSLocalizedString("ok", comment: ""),
            cancelText: NSLocalizedString("cancel", comment: ""),
            from: from,
            completion: completion)
    }
    
    static public func ask(message: String,
                           okText: String,
                           cancelText: String,
                           from: UIViewController,
                           completion: AlertBoolCompletion?) {
        ask(title: NSLocalizedString("warning", comment: ""),
            message: message,
            actions: [
                AlertActionClosure(title: okText, completion: { _ in
                    guard let completion = completion else { return }
                    completion(true)
                }),
                AlertActionClosure(title: cancelText, completion: { _ in
                    guard let completion = completion else { return }
                    completion(false)
                })
            ],
            from: from)
    }
    
    static public func ask(title: String,
                           message: String,
                           okText: String,
                           cancelText: String,
                           from: UIViewController,
                           completion: AlertBoolCompletion?) {
        ask(title: title,
            message: message,
            actions: [
                AlertActionClosure(title: okText, completion: { _ in
                    guard let completion = completion else { return }
                    completion(true)
                }),
                AlertActionClosure(title: cancelText, completion: { _ in
                    guard let completion = completion else { return }
                    completion(false)
                })
            ],
            from: from)
    }
    
}

