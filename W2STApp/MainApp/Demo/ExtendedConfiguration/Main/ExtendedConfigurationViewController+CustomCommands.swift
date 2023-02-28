//
//  ExtendedConfigurationViewController+CustomCommands.swift
//  W2STApp
//
//  Created by Dimitri Giani on 30/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit

extension ExtendedConfigurationViewController {
    internal func sendCustomCommand(_ command: ECCustomCommand) {
        switch command.type {
            case .integer:
                showCustomIntegerAlert(command: command)
            case .string:
                showCustomStringAlert(command: command)
            case .bool:
                showBoolAlert(command: command)
            case .enumString:
                showEnumStringSelector(command: command)
            case .enumInteger:
                showEnumIntSelector(command: command)
            case .void:
                feature?.sendCommand(command.name)
        }
    }
    
    internal func sendCustomCommand(_ command: ECCustomCommand, string: String) {
        feature?.sendCommand(command.name, string: string)
    }
    
    internal func sendCustomCommand(_ command: ECCustomCommand, int: Int) {
        feature?.sendCommand(command.name, int: int)
    }
    
    internal func showEnumStringSelector(command: ECCustomCommand) {
        var actions: [UIAlertAction] = command.stringValues?.compactMap { item in
            UIAlertAction(title: item, style: .default) { [weak self] _ in
                self?.sendCustomCommand(command, string: item)
            }
        } ?? []
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentActionSheet(from: self, title: command.name, message: command.note, actions: actions)
    }
    
    internal func showEnumIntSelector(command: ECCustomCommand) {
        var actions: [UIAlertAction] = command.integerValuesFormatted.compactMap { item in
            UIAlertAction(title: item, style: .default) { [weak self] _ in
                let index = command.integerValuesFormatted.firstIndex { $0 == item } ?? 0
                let value = command.integerValues?[index] ?? 0
                self?.sendCustomCommand(command, int: value)
            }
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentActionSheet(from: self, title: command.name, message: command.note, actions: actions)
    }
    
    internal func showCustomStringAlert(command: ECCustomCommand) {
        var aTextField: UITextField?
        let confirmButton = UIAlertAction.genericButton("OK".localizedFromGUI) { [weak self] _ in
            if let text = aTextField?.text, !text.isEmpty, command.isValidString(text) {
                self?.sendCustomCommand(command, string: text)
            }
        }
        let message = "ext.command.custom.limits.string".localizedFromGUI(arguments: [command.minValueDesc, command.maxValueDesc])
        let body = message + "\n\(command.minValueDesc)/\(command.maxValueDesc)"
        
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: command.note ?? command.name,
                                                message: body,
                                                confirmButton: confirmButton,
                                                cancelButton: UIAlertAction.cancelButton()) { [weak self] textfield, controller in
            aTextField = textfield
            textfield.placeholder = self?.node.name
            textfield.onKeyPress { [weak controller] text in
                
                let isValid = command.isValidString(text)
                defer {
                    let body = message + "\n\(text.count)/\(command.maxValueDesc)"
                    
                    if !isValid {
                        let isMaxError = text.count >= command.maxValue
                        if isMaxError {
                            controller?.message = body + "\n" +  "ext.command.custom.max.chars.error".localizedFromGUI(arguments: [command.maxValueDesc])
                        } else {
                            controller?.message = body + "\n" + "ext.command.custom.min.chars.error".localizedFromGUI(arguments: [command.minValueDesc])
                        }
                    } else {
                        controller?.message = body
                    }
                }
                return true
            }
        }
    }
    
    internal func showCustomIntegerAlert(command: ECCustomCommand) {
        var aTextField: UITextField?
        let confirmButton = UIAlertAction.genericButton("OK".localizedFromGUI) { [weak self] _ in
            if let text = aTextField?.text, !text.isEmpty,
               let number = NumberFormatter().number(from: text)?.intValue,
               command.isValidInt(number) {
                self?.sendCustomCommand(command, int: number)
            }
        }
        let message = "ext.command.custom.limits.int".localizedFromGUI(arguments: [command.minValueDesc, command.maxValueDesc])
        
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: command.note ?? command.name,
                                                message: message,
                                                confirmButton: confirmButton,
                                                cancelButton: UIAlertAction.cancelButton()) { [weak self] textfield, controller in
            aTextField = textfield
            textfield.placeholder = self?.node.name
            textfield.keyboardType = .numbersAndPunctuation
            textfield.onKeyPress { [weak controller] text in
                
                let number = NumberFormatter().number(from: text)?.intValue ?? 0
                let isValid = command.isValidInt(number)
                defer {
                    if !isValid {
                        let isMaxError = number >= command.maxValue
                        if isMaxError {
                            controller?.message = message + "\n" +  "ext.command.custom.max.int.error".localizedFromGUI(arguments: [command.maxValueDesc])
                        } else {
                            controller?.message = message + "\n" + "ext.command.custom.min.int.error".localizedFromGUI(arguments: [command.minValueDesc])
                        }
                    } else {
                        controller?.message = message
                    }
                }
                return true
            }
        }
    }
    
    internal func showBoolAlert(command: ECCustomCommand) {
        let view = UIView()
        let label = UILabel()
        let switchView = UISwitch()
        let stackView = UIStackView.getHorizontalStackView(withSpacing: 4, views: [label, switchView])
        view.addSubviewAndFit(stackView, top: 16, trailing: 16, bottom: 16, leading: 16)
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "ext.commands.custom.boolean.title".localizedFromGUI
        
        let controller = UIAlertController(title: command.note ?? command.name, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction.genericButton("OK".localizedFromGUI, { [weak self, weak switchView] _ in
            let value = (switchView?.isOn ?? false).string
            self?.sendCustomCommand(command, string: value)
        }))
        controller.addAction(UIAlertAction.cancelButton())
        
        controller.view.addSubview(view, constraints: [
            equal(\.topAnchor, constant: 60),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -60),
        ])
        
        present(controller, animated: true, completion: nil)
    }
}
