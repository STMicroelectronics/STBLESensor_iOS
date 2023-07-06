//
//  GestureNavigationPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class GestureNavigationPresenter: DemoPresenter<GestureNavigationViewController> {

}

// MARK: - GestureNavigationViewControllerDelegate
extension GestureNavigationPresenter: GestureNavigationDelegate {

    func load() {
        demo = .gestureNavigation
        
        demoFeatures = param.node.characteristics.features(with: Demo.gestureNavigation.features)
        
        view.configureView()
    }
    
    public func updateGestureLabel(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<GestureNavigationData>,
           let data = sample.data {
            view.gestureLabel.text = data.gesture.value?.description
            if let gestureRawValue = data.gesture.value?.rawValue {
                if let buttonRawValue = data.button.value?.rawValue {
                    animateArrows(value: [buttonRawValue: gestureRawValue])
                }
            }
        }
    }
    
    private func animateArrows(value: [UInt8:UInt8]) {
        switch value {
        case [0:1]:
            showLEFTRIGHTbutton()
            animateHorizontalRight()
        case [0:2]:
            showLEFTRIGHTbutton()
            animateHorizontalLeft()
        case [0:3]:
            showUPDOWNbutton()
            animateVerticalUp()
        case [0:4]:
            showUPDOWNbutton()
            animateVerticalDown()
        case [1:5], [1:6], [1:7]:
            showLEFTbutton()
            animateFastPulse(self.view.navLeftArrow)
        case [1:8]:
            showLEFTbutton()
            animateSlowPulse(self.view.navLeftArrow)
        case [2:5], [2:6], [2:7]:
            showRIGHTbutton()
            animateFastPulse(self.view.navRightArrow)
        case [2:8]:
            showRIGHTbutton()
            animateSlowPulse(self.view.navRightArrow)
        case [3:5], [3:6], [3:7]:
            showUPbutton()
            animateFastPulse(self.view.navUpArrow)
        case [3:8]:
            showUPbutton()
            animateSlowPulse(self.view.navUpArrow)
        case [4:5], [4:6], [4:7]:
            showDOWNbutton()
            animateFastPulse(self.view.navDownArrow)
        case [4:8]:
            showDOWNbutton()
            animateSlowPulse(self.view.navDownArrow)
        default:
            break
        }
    }

    /** → RIGHT → */
    func animateHorizontalRight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.navRightArrow.transform = CGAffineTransform(translationX: 0 + 20, y: 0)
            self.view.navLeftArrow.transform = CGAffineTransform(translationX: 0 + 20, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.view.navRightArrow.transform = CGAffineTransform.identity
                self.view.navLeftArrow.transform = CGAffineTransform.identity
            }
        }
    }
    
    /** ← LEFT ← */
    func animateHorizontalLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.navRightArrow.transform = CGAffineTransform(translationX: 0 - 20, y: 0)
            self.view.navLeftArrow.transform = CGAffineTransform(translationX: 0 - 20, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.view.navRightArrow.transform = CGAffineTransform.identity
                self.view.navLeftArrow.transform = CGAffineTransform.identity
            }
        }
    }
    
    /** ↑ UP ↑ */
    func animateVerticalUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.navUpArrow.transform = CGAffineTransform(translationX: 0, y: 0 + 20)
            self.view.navDownArrow.transform = CGAffineTransform(translationX: 0, y: 0 + 20)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.view.navUpArrow.transform = CGAffineTransform.identity
                self.view.navDownArrow.transform = CGAffineTransform.identity
            }
        }
    }
    
    /** ↓ DOWN ↓  */
    func animateVerticalDown() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.navUpArrow.transform = CGAffineTransform(translationX: 0, y: 0 - 20)
            self.view.navDownArrow.transform = CGAffineTransform(translationX: 0, y: 0 - 20)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.view.navUpArrow.transform = CGAffineTransform.identity
                self.view.navDownArrow.transform = CGAffineTransform.identity
            }
        }
    }
    
    /** FAST PULSE  */
    func animateFastPulse(_ button: UIImageView) {
        UIView.animate(withDuration: 0.3, animations: {
            button.layer.opacity = 0
        }) { _ in
            button.layer.opacity = 1
        }
    }
    
    /** SLOW PULSE  */
    func animateSlowPulse(_ button: UIImageView) {
        UIView.animate(withDuration: 0.7, animations: {
            button.layer.opacity = 0
        }) { _ in
            button.layer.opacity = 1
        }
    }
    
    func showLEFTbutton() {
        self.view.navUpArrow.alpha = 0
        self.view.navDownArrow.alpha = 0
        self.view.navLeftArrow.alpha = 1
        self.view.navRightArrow.alpha = 0
    }
    
    func showRIGHTbutton() {
        self.view.navUpArrow.alpha = 0
        self.view.navDownArrow.alpha = 0
        self.view.navLeftArrow.alpha = 0
        self.view.navRightArrow.alpha = 1
    }
    
    func showUPbutton() {
        self.view.navUpArrow.alpha = 1
        self.view.navDownArrow.alpha = 0
        self.view.navLeftArrow.alpha = 0
        self.view.navRightArrow.alpha = 0
    }
    
    func showDOWNbutton() {
        self.view.navUpArrow.alpha = 0
        self.view.navDownArrow.alpha = 1
        self.view.navLeftArrow.alpha = 0
        self.view.navRightArrow.alpha = 0
    }
    
    func showUPDOWNbutton() {
        self.view.navUpArrow.alpha = 1
        self.view.navDownArrow.alpha = 1
        self.view.navLeftArrow.alpha = 0
        self.view.navRightArrow.alpha = 0
    }
    
    func showLEFTRIGHTbutton() {
        self.view.navUpArrow.alpha = 0
        self.view.navDownArrow.alpha = 0
        self.view.navLeftArrow.alpha = 1
        self.view.navRightArrow.alpha = 1
    }
}
