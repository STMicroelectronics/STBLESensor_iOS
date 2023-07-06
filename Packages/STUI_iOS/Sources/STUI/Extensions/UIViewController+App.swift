//
//  UIViewController+App.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public typealias TargetCompletion = () -> Void

extension UIViewController {

    private class TargetCompletionWrapper: NSObject {
        let closure: TargetCompletion
        init(_ closure: @escaping TargetCompletion) {
            self.closure = closure
        }
    }

    private struct AssociatedKeys {
        static var foregroundClosure = "foregroundClosure"
        static var backgroundClosure = "backgroundClosure"
    }

    // swiftlint:disable line_length
    private var foregroundClosure: TargetCompletion? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.foregroundClosure) as? TargetCompletionWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.foregroundClosure, TargetCompletionWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var backgroundClosure: TargetCompletion? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.backgroundClosure) as? TargetCompletionWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundClosure, TargetCompletionWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // swiftlint:enable line_length

    public func handleAppStateForeground(foregroundClosure: TargetCompletion?,
                                  background backgroundClosure: TargetCompletion? = nil) {

        self.foregroundClosure = foregroundClosure
        self.backgroundClosure = backgroundClosure

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }

    public func cancelAppStateHandlers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func appMovedToForeground() {
        guard let colusere = foregroundClosure else { return }

        colusere()
    }

    @objc func appMovedToBackground() {
        guard let colusere = backgroundClosure else { return }

        colusere()
    }

}
