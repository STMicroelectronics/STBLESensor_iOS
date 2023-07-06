//
//  MemsGesturePresenter.swift
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

final class MemsGesturePresenter: DemoPresenter<MemsGestureViewController> {
    static let DEFAULT_ALPHA = CGFloat(0.3)
    static let SELECTED_ALPHA = CGFloat(1.0)
    static let ANIMATION_LENGTH = TimeInterval(1.0/3.0)
    static let AUTOMATIC_DESELECT_TIMEOUT_SEC = TimeInterval(3.0)
    var mLastUpdate: Date?
    var mCurrenctSlected: GestureType?
}

// MARK: - MemsGestureViewControllerDelegate
extension MemsGesturePresenter: MemsGestureDelegate {

    func load() {
        demo = .memsGesture
        
        demoFeatures = param.node.characteristics.features(with: Demo.memsGesture.features)
        
        view.configureView()
    }

    func updateMemsGestureUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<MemsGestureData>,
           let data = sample.data {
            if let gesture = data.gesture.value {
                updateUIBasedOnGesture(gesture)
            }
        }
    }
    
    private func updateUIBasedOnGesture(_ gesture: GestureType) {
        guard let newImage = view.mGestureToImage[gesture] else{
            return
        }

        if let  current = mCurrenctSlected{
            view.mGestureToImage[current]?.alpha = MemsGesturePresenter.DEFAULT_ALPHA
        }
        
        mCurrenctSlected=gesture
        newImage.alpha = MemsGesturePresenter.SELECTED_ALPHA
        newImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: MemsGesturePresenter.ANIMATION_LENGTH){
            newImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        let now = Date()
        mLastUpdate = now

        DispatchQueue.main.asyncAfter(deadline: .now()+MemsGesturePresenter.AUTOMATIC_DESELECT_TIMEOUT_SEC) { [weak self, weak newImage] in
            if(self?.mLastUpdate == now) {
                newImage?.alpha = MemsGesturePresenter.DEFAULT_ALPHA
            }
        }
    }
    
}
