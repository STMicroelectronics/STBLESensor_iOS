//
//  UITextView+Extensions.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 27/05/21.
//

import Foundation

extension UITextView: UITextViewDelegate {
    public typealias OnKeyPressCompletion = (String) -> Bool
    
    private struct AssociatedKeys {
        static var OnKeyPressCompletion = "OnKeyPressCompletion"
    }
    
    public func onKeyPress(_ handler: @escaping OnKeyPressCompletion) {
        let wrapper: Atomic<OnKeyPressCompletion> = Atomic(handler)
        
        objc_setAssociatedObject(self, &AssociatedKeys.OnKeyPressCompletion, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        delegate = self
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let completion = objc_getAssociatedObject(self, &AssociatedKeys.OnKeyPressCompletion) as? Atomic<OnKeyPressCompletion> {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            
            return completion.value(updatedText)
        }
        
        return true
    }
}
