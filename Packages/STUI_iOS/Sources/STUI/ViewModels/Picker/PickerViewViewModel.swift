//
//  PickerViewViewModel.swift
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

public class PickerInput {
    public var title: String?
    public var selection: BoxedValue?
    public var options: [ BoxedValue ]?
    public var isEnabled: Bool

    public init(title: String? = nil,
                selection: BoxedValue? = nil,
                options: [BoxedValue]? = nil,
                isEnabled: Bool = true) {
        self.title = title
        self.selection = selection
        self.options = options
        self.isEnabled = isEnabled
    }
}

public class PickerViewViewModel: BaseViewModel<CodeValue<PickerInput>, PickerView> {

    public var handleSelectionTouched: (CodeValue<PickerInput>) -> Void

    public init(param: CodeValue<PickerInput>,
                layout: Layout? = nil,
                handleSelectionTouched: @escaping (CodeValue<PickerInput>) -> Void) {
        self.handleSelectionTouched = handleSelectionTouched
        super.init(param: param, layout: layout)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: PickerView) {

        if let layout = layout {
            layout.textLayout?.apply(to: view.titleLabel)
        }

        view.titleLabel.text = param?.value.title
        view.valueLabel.text = nil
        view.actionButton.isEnabled = param?.value.isEnabled ?? false
        view.valueLabel.isEnabled = param?.value.isEnabled ?? false

        view.actionButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self, let param = self.param else { return }

            self.handleSelectionTouched(param)
        }

        guard let index = param?.value.selection else { return }

        if case let .int(indexValue) = index {
            view.valueLabel.text = param?.value.options?[indexValue].description
        }
    }

    public override func update(view: PickerView, values: [any KeyValue]) {

        guard let index = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }

        param?.value.selection = index

        if case let .int(indexValue) = index {
            view.valueLabel.text = param?.value.options?[indexValue].description
        }
    }

    public override func update(with values: [any KeyValue]) {
        guard let index = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue else { return }

        param?.value.selection = index
    }
}
