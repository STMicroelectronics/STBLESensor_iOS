//
//  UIView+Tap.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 14/01/21.
//

import UIKit

extension UIView
{
    public typealias TapCompletion = (_ gesture: UITapGestureRecognizer)->()
    
    private struct AssociatedKeys {
        static var TapCompletion = "TapCompletion"
    }
    
    public func onTap(_ handler: @escaping TapCompletion)
    {
        let wrapper: Atomic<TapCompletion> = Atomic(handler)
        
        objc_setAssociatedObject(self, &AssociatedKeys.TapCompletion, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        addGestureRecognizer(gesture)
        
        isUserInteractionEnabled = true
    }
    
    @objc private func tapHandler(gesture: UITapGestureRecognizer)
    {
        if let completion = objc_getAssociatedObject(self, &AssociatedKeys.TapCompletion) as? Atomic<TapCompletion>
        {
            completion.value(gesture)
        }
    }
}
