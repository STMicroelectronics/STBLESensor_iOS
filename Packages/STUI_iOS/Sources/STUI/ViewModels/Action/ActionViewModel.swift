//
//  ActionViewModel.swift
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

public class ActionInput {
    public var title: String?
    public var actionTitle: String?

    public init(title: String? = nil,
                actionTitle: String? = nil) {
        self.title = title
        self.actionTitle = actionTitle
    }
}

public class ActionViewModel: BaseViewModel<CodeValue<ActionInput>, ActionView> {

    private var handleButtonTouched: (CodeValue<ActionInput>) -> Void
    
    public init(param: CodeValue<ActionInput>?,
                layout: Layout? = nil,
                handleButtonTouched: @escaping (CodeValue<ActionInput>) -> Void) {
        self.handleButtonTouched = handleButtonTouched
        super.init(param: param, layout: layout)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: ActionView) {

        view.titleLabel.text = param?.value.title
        view.actionButton.setTitle(param?.value.actionTitle, for: .normal)

        if let layout = layout {
            view.actionButton.setTitle(nil, for: .normal)
            layout.textLayout?.apply(to: view.titleLabel)
            layout.buttonLayout?.apply(to: view.actionButton, text: param?.value.actionTitle)
        }

        view.handleButtonTouched = { [weak self] in
            guard let self = self, let param = self.param else { return }
            self.handleButtonTouched(param)
        }
    }

    public override func update(view: ActionView, values: [any KeyValue]) {

        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }
    }

    public override func update(with values: [any KeyValue]) {
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }
    }
}

