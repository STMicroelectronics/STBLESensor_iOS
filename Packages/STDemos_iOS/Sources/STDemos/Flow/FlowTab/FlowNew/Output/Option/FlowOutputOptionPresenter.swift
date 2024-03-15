//
//  FlowOutputOptionPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class FlowOutputOptionPresenter: BasePresenter<FlowOutputOptionViewController, Output> {
    var valid: Bool = true
}

// MARK: - FlowOutputOptionViewControllerDelegate
extension FlowOutputOptionPresenter: FlowOutputOptionDelegate {

    func load() {
        view.configureView()
        
        view.title = param.descr
        
        guard let properties = param.properties else { return }

        for (index, property) in properties.enumerated() {
            switch property.descriptor {
            case .bool(let value):
                addCheckbox(index, property: property, value: value)
            case .float:
                break
            case .intRange(let value, let min, let max):
                addTextField(index, property: property, value: value, min: min, max:max)
            case .radio:
                break
            case .string(let value):
                addTextField(index, property: property, value: value)
            case .unsupported:
                break
            }
        }
    }

    func doneButtonTapped() {
        guard valid else { return }
        self.view.dismiss(animated: true)
    }
    
    func cancelButtonTapped() {
        self.view.dismiss(animated: true)
    }
}

extension FlowOutputOptionPresenter {

    func addCheckbox(_ index: Int, property: Property, value: Bool) {
        let fakeCheckable = FakeCheckable(identifier: "", descr: property.label)
        let checkbox: CheckBoxRow = CheckBoxRow.createFromNib()

        checkbox.configureCheckWith(fakeCheckable, checked: value)

        checkbox.addCompletion { [weak self] result in
            guard let self = self else { return }

            self.param.properties?[index].update(descriptor: Descriptior.bool(value: result))
            checkbox.configureCheckWith(fakeCheckable, checked: result)
        }

        view.stackView.addArrangedSubview(checkbox)
    }

    func addTextField(_ index: Int, property: Property, value: String) {
        let textField = TextField()
        textField.titleText = property.label
        textField.text = value
        textField.addDoneButtonToKeyboard()
        textField.configure { [weak self] text in
            guard let self = self, let text = text else { return }

            self.param.properties?[index].update(descriptor: Descriptior.string(value: text))
        }

        view.stackView.addArrangedSubview(textField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)))
    }

    func addTextField(_ index: Int, property: Property, value: Int, min: Int? , max: Int?) {
        let textField = TextField()
        textField.titleText = property.label
        textField.text = String(value)
        textField.addDoneButtonToKeyboard()
        textField.keyboardType = .numberPad
        textField.configure { [weak self] text in
            guard let self = self else { return }

            guard let text = Int(text ?? ""), textField.validate().boolValue() else {
                self.valid = false
                return
            }

            self.param.properties?[index].update(descriptor: Descriptior.intRange(value: text, min: nil, max: nil))
            self.valid = true
        }

         textField.validators = [ IntRangeValueValidator(min: min, max: max, errorMessage: "The entered value is not allowed")]

        view.stackView.addArrangedSubview(textField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)))
    }
}
