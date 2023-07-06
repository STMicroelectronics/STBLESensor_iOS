//
//  ActionPickerViewModel.swift
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

public class ActionPickerInput: PickerInput {

    public var actionTitle: String?

    public init(title: String? = nil,
                actionTitle: String? = nil,
                selection: BoxedValue? = nil,
                options: [BoxedValue]? = nil,
                isEnabled: Bool = true) {
        self.actionTitle = actionTitle
        super.init(title: title,
                   selection: selection,
                   options: options,
                   isEnabled: isEnabled)
    }
}

public class ActionPickerViewModel: BaseViewModel<CodeValue<ActionPickerInput>, ActionPickerView> {

    public var handleSelectionTouched: (CodeValue<ActionPickerInput>) -> Void
    public var handleButtonTouched: (CodeValue<ActionPickerInput>) -> Void
    
    public init(param: CodeValue<ActionPickerInput>,
                layout: Layout? = nil,
                handleSelectionTouched: @escaping (CodeValue<ActionPickerInput>) -> Void,
                handleButtonTouched: @escaping (CodeValue<ActionPickerInput>) -> Void) {
        
        self.handleSelectionTouched = handleSelectionTouched
        self.handleButtonTouched = handleButtonTouched

        super.init(param: param, layout: layout)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: ActionPickerView) {
        
        view.titleLabel.text = param?.value.title
        view.actionButton.setTitle(param?.value.actionTitle, for: .normal)

        if let layout = layout {
            view.actionButton.setTitle(nil, for: .normal)
            layout.textLayout?.apply(to: view.titleLabel)
            layout.buttonLayout?.apply(to: view.actionButton, text: param?.value.actionTitle)
        }

        view.actionButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self, let param = self.param else { return }
            self.handleButtonTouched(param)
        }

        view.pickerButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self, let param = self.param else { return }
            self.handleSelectionTouched(param)
        }
    }

    public override func update(view: ActionPickerView, values: [any KeyValue]) {

        guard let index = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }

        param?.value.selection = index

        if case let .int(indexValue) = index {
            view.pickerLabel.text = param?.value.options?[indexValue].description
        }
    }

    public override func update(with values: [any KeyValue]) {
        guard let index = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }

        param?.value.selection = index
    }
}

