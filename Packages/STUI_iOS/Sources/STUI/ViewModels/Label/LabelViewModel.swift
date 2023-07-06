//
//  LabelViewModel.swift
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

public protocol KeyValue: Hashable, Equatable {
    associatedtype Value

    var keys: [String] { get set }
    var value: Value { get set }
}

public extension KeyValue {
    var boxedValue: BoxedValue? {
        if let value = value as? String {
            return value.boxedValue
        } else if let value = value as? Int {
            return value.boxedValue
        } else if let value = value as? Double {
            return value.boxedValue
        } else if let value = value as? Bool {
            return value.boxedValue
        }

        return nil
    }
}

public class CodeValue<Value>: KeyValue {
    public var keys: [String]
    public var value: Value

    public init(keys: [String], value: Value) {
        self.keys = keys
        self.value = value
    }

    public init(value: Value) {
        self.keys = [ UUID().uuidString ]
        self.value = value
    }
}

extension CodeValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        for key in keys {
            hasher.combine(key)
        }
    }
}

extension CodeValue: Equatable {
    public static func == (lhs: CodeValue<Value>, rhs: CodeValue<Value>) -> Bool {
        lhs.keys == rhs.keys
    }
}

public class LabelViewModel: BaseViewModel<CodeValue<String>, LabelView> {

    private var image: UIImage?
    private var handleTap: ((CodeValue<String>) -> Void)?

    public init(param: CodeValue<String>?,
                layout: Layout? = nil,
                image: UIImage? = nil,
                handleTap: ((CodeValue<String>) -> Void)? = nil) {
        self.image = image
        self.handleTap = handleTap
        super.init(param: param, layout: layout)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: LabelView) {
        view.textLabel.text = param?.value
        view.actionImageView.isHidden = image == nil
        view.actionImageView.contentMode = .center

        view.actionImageView.image = image

        if let layout = layout {
            layout.textLayout?.apply(to: view.textLabel)
        }

        if let handleTap = handleTap, let param = param {
            view.actionButton.addAction(for: .touchUpInside) { _ in
                handleTap(param)
            }
        }
    }

    public override func update(view: LabelView, values: [any KeyValue]) {

        guard let values = values.filter({ $0 is CodeValue<String> }) as? [CodeValue<String>],
            let value = values.first(where: { $0 == param}) else { return }

        param?.value = value.value
        view.textLabel.text = param?.value
    }

}
