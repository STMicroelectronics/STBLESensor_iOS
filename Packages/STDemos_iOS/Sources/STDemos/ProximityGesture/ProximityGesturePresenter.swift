//
//  ProximityGesturePresenter.swift
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

final class ProximityGesturePresenter: DemoPresenter<ProximityGestureViewController> {
    static let DEFAULT_ALPHA = 0.3
    static let SELECTED_ALPHA = 1.0
}

// MARK: - ProximityGestureViewControllerDelegate
extension ProximityGesturePresenter: ProximityGestureDelegate {

    func load() {
        demo = .proximity
        
        demoFeatures = param.node.characteristics.features(with: Demo.proximity.features)
        
        view.configureView()
    }
    
    func switchOffImage() {
        view.proximityGestureTap.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
        view.proximityGestureLeftArrow.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
        view.proximityGestureRightArrow.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
    }
    
    func updateProximityUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<ProximityGestureData>,
           let data = sample.data {
            updateProximityGestureNavigationView(data)
        }
    }

    private func updateProximityGestureNavigationView(_ data: ProximityGestureData) {
        switch data.gesture.value {
        case .tap:
            animateSelectedProximityGesture(view.proximityGestureTap)
            view.proximityGestureTap.alpha = ProximityGesturePresenter.SELECTED_ALPHA
            view.proximityGestureLeftArrow.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
            view.proximityGestureRightArrow.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
        case .left:
            animateSelectedProximityGesture(view.proximityGestureLeftArrow)
            view.proximityGestureTap.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
            view.proximityGestureLeftArrow.alpha = ProximityGesturePresenter.SELECTED_ALPHA
            view.proximityGestureRightArrow.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
        case .right:
            animateSelectedProximityGesture(view.proximityGestureRightArrow)
            view.proximityGestureTap.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
            view.proximityGestureLeftArrow.alpha = ProximityGesturePresenter.DEFAULT_ALPHA
            view.proximityGestureRightArrow.alpha = ProximityGesturePresenter.SELECTED_ALPHA
        default:
            print("Proximity Gesture NO Action")
        }
    }
    
    private func animateSelectedProximityGesture(_ imageView: UIImageView) {
        func animate() {
            UIImageView.animate(withDuration: 0.3, animations: {
                imageView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }) { _ in
                UIImageView.animate(withDuration : 1, animations: {
                    imageView.transform = CGAffineTransformIdentity
                })
            }
        }
    }
}
