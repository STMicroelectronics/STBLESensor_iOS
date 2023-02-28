//
//  OutputOptionsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 29/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class OutputOptionsViewController: OptionsViewController<Output> {

    var valid: Bool = true

    let textFieldEdgeInsets = UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)

    override func rightButtonPressed() {
        guard valid else { return }

        super.rightButtonPressed()
    }

    override func configureView(with item: Output) {
        navigationItem.title = "output_options".localized()

        guard let properties = item.properties else { return }

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
}

extension OutputOptionsViewController {

    func addCheckbox(_ index: Int, property: Property, value: Bool) {
        let fakeCheckable = FakeCheckable(identifier: "", descr: property.label)
        let checkbox: CheckBoxRow = CheckBoxRow.createFromNib()

        checkbox.configureCheckWith(fakeCheckable, checked: value)

        checkbox.addCompletion { [weak self] result in
            guard let self = self else { return }

            self.item?.properties?[index].update(descriptor: Descriptior.bool(value: result))
            checkbox.configureCheckWith(fakeCheckable, checked: result)
        }

        stackView.addArrangedSubview(checkbox)
    }

    func addTextField(_ index: Int, property: Property, value: String) {
        let textField = TextField()
        textField.titleText = property.label
        textField.text = value
        textField.addDoneButtonToKeyboard()
        textField.configure { [weak self] text in
            guard let self = self, let text = text else { return }

            self.item?.properties?[index].update(descriptor: Descriptior.string(value: text))
        }

        stackView.addArrangedSubview(textField.embedInView(with: textFieldEdgeInsets))
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

            self.item?.properties?[index].update(descriptor: Descriptior.intRange(value: text, min: nil, max: nil))
            self.valid = true
        }

         textField.validators = [ IntRangeValueValidator(min: min, max: max, errorMessage: "err_value_not_allowed".localized())]

        stackView.addArrangedSubview(textField.embedInView(with: textFieldEdgeInsets))
    }
}
