//
//  ActionTextInput.swift
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

public class ActionTextInput {

    public var title: String?
    public var actionTitle: String?
    public var value: String?

    public var handleButtonTouched: (CodeValue<ActionTextInput>) -> Void

    public init(title: String? = nil,
                actionTitle: String? = nil,
                value: String? = nil,
                handleButtonTouched: @escaping (CodeValue<ActionTextInput>) -> Void) {
        self.title = title
        self.actionTitle = actionTitle
        self.value = value
        self.handleButtonTouched = handleButtonTouched
    }
}

public class ActionTextViewModel: BaseViewModel<CodeValue<ActionTextInput>, ActionTextView> {

    public override func configure(view: ActionTextView) {
        
        view.titleLabel.text = param?.value.title
        view.actionButton.setTitle(param?.value.actionTitle, for: .normal)

        if let layout = layout {
            view.actionButton.setTitle(nil, for: .normal)
            layout.textLayout?.apply(to: view.titleLabel)
            layout.buttonLayout?.apply(to: view.actionButton, text: param?.value.actionTitle)
        }

        view.handleButtonTouched = { [weak self] in
            self?.param?.value.value = view.textField.text
            guard let self = self, let param = self.param else { return }
            self.param?.value.handleButtonTouched(param)
        }
    }

    public override func update(view: ActionTextView, values: [any KeyValue]) {

        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }
    }

    public override func update(with values: [any KeyValue]) {
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }
    }
}

