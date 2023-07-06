//
//  ButtonViewModel.swift
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

public enum ButtonAlignment {
    case left
    case right
    case center
}

public class ButtonInput {
    public var alignment: ButtonAlignment
    public var title: String?

    public init(title: String? = nil, alignment: ButtonAlignment = .center) {
        self.title = title
        self.alignment = alignment
    }
}

public class ButtonViewModel: BaseViewModel<CodeValue<ButtonInput>, ButtonView> {

    private var handleButtonTouched: (CodeValue<ButtonInput>) -> Void

    public init(param: CodeValue<ButtonInput>?,
                layout: Layout? = nil,
                handleButtonTouched: @escaping (CodeValue<ButtonInput>) -> Void) {
        self.handleButtonTouched = handleButtonTouched
        super.init(param: param, layout: layout)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: ButtonView) {

        view.actionButton.setTitle(param?.value.title, for: .normal)

        view.leftEmptyView.isHidden = true
        view.rightEmptyView.isHidden = true

        switch param?.value.alignment {
        case .left:
            view.rightEmptyView.isHidden = false
        case .right:
            view.leftEmptyView.isHidden = false
        default:
            break

        }

        if let layout = layout {
            view.actionButton.setTitle(nil, for: .normal)
            layout.buttonLayout?.apply(to: view.actionButton,
                                       text: param?.value.title)
        }

        view.handleButtonTouched = { [weak self] in
            guard let self = self, let param = self.param else { return }
            self.handleButtonTouched(param)
        }
    }

    public override func update(view: ButtonView, values: [any KeyValue]) {

        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue, case let .string(string) = value else { return }

        param?.value.title = string

        if let layout = layout {
            view.actionButton.setTitle(nil, for: .normal)
            layout.buttonLayout?.apply(to: view.actionButton,
                                       text: string)
        }
    }

    public override func update(with values: [any KeyValue]) {
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) })?.boxedValue, case let .string(string) = value else { return }

        param?.value.title = string
    }
}
