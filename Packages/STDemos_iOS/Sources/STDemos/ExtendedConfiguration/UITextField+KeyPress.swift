//
//  UITextField+KeyPress.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class Atomic<A> {
    private let queue = DispatchQueue(label: "AtomicQueueSerial")
    private var _value: A

    public init(_ value: A) {
        self._value = value
    }

    public var value: A {
        get {
            return queue.sync { self._value }
        }
        set {
            queue.sync { self._value = newValue }
        }
    }
}

extension UITextField: UITextFieldDelegate {
    public typealias OnKeyPressCompletion = (String) -> Bool

    private struct AssociatedKeys {
        static var OnKeyPressCompletion = "OnKeyPressCompletion"
    }

    public func onKeyPress(_ handler: @escaping OnKeyPressCompletion) {
        let wrapper: Atomic<OnKeyPressCompletion> = Atomic(handler)

        objc_setAssociatedObject(self, &AssociatedKeys.OnKeyPressCompletion, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        delegate = self
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let completion = objc_getAssociatedObject(self, &AssociatedKeys.OnKeyPressCompletion) as? Atomic<OnKeyPressCompletion> {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            return completion.value(updatedText)
        }

        return true
    }
}
