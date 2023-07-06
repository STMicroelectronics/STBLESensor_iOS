//
//  UITapGestureRecognizerWithClosure.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

class UITapGestureRecognizerWithClosure: UITapGestureRecognizer {
    private var invokeTarget:UIGestureRecognizerInvokeTarget

    init(closure:@escaping (UIGestureRecognizer) -> ()) {
        // we need to make a separate class instance to pass
        // to super.init because self is not available yet
        self.invokeTarget = UIGestureRecognizerInvokeTarget(closure: closure)
        super.init(target: invokeTarget, action: #selector(invokeTarget.invoke(fromTarget:)))
    }
}

// this class defines an object with a known selector
// that we can use to wrap our closure
class UIGestureRecognizerInvokeTarget: NSObject {
    private var closure:(UIGestureRecognizer) -> ()

    init(closure:@escaping (UIGestureRecognizer) -> ()) {
        self.closure = closure
        super.init()
    }

    @objc public func invoke(fromTarget gestureRecognizer: UIGestureRecognizer) {
        self.closure(gestureRecognizer)
    }
}
