//
//  TextInputViewModel.swift
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

public class TextInput {
    public var title: String?
    public var boxedValue: BoxedValue?
    public var isEnabled: Bool
    public var handleChangeText: (CodeValue<TextInput>) -> Void

    public init(title: String? = nil,
                boxedValue: BoxedValue? = nil,
                isEnabled: Bool,
                handleChangeText: @escaping (CodeValue<TextInput>) -> Void) {
        self.title = title
        self.boxedValue = boxedValue
        self.isEnabled = isEnabled
        self.handleChangeText = handleChangeText
    }
}

public class TextInputViewModel: BaseViewModel<CodeValue<TextInput>, TextInputView> {

    public override func configure(view: TextInputView) {

        if let layout = layout {
            layout.textLayout?.apply(to: view.titleLabel)
        }

        view.titleLabel.text = param?.value.title
        view.textField.text = param?.value.boxedValue?.description
        view.textField.isEnabled = param?.value.isEnabled ?? false

        view.handleChangeText = { [weak self] text in
            guard let self = self else { return }

//            if case .int = self.param?.value.boxedValue,
//               let value = Int(text) {
//                self.param?.value.boxedValue = .int(value)
//            } else if case .string = self.param?.value.boxedValue {
//                self.param?.value.boxedValue = .string(text)
//            }

            if let value = Int(text) {
                self.param?.value.boxedValue = .int(value)
            } else {
                self.param?.value.boxedValue = .string(text)
            }

            guard let param = self.param else { return }

            self.param?.value.handleChangeText(param)
        }
    }

    public override func update(view: TextInputView, values: [any KeyValue]) {
        
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }

        param?.value.boxedValue = value
        view.titleLabel.text = param?.value.title
        view.textField.text = param?.value.boxedValue?.description
    }

    public override func update(with values: [any KeyValue]) {
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }

        param?.value.boxedValue = value
    }
}

