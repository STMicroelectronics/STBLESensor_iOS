//
//  CarryPositionPresenter.swift
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

final class CarryPositionPresenter: DemoPresenter<CarryPositionViewController> {
    static let DEFAULT_ALPHA = CGFloat(0.3)
    static let SELECTED_ALPHA = CGFloat(1.0)
    var mCurrentPosition: CarryPositionType?
}

// MARK: - CarryPositionViewControllerDelegate
extension CarryPositionPresenter: CarryPositionDelegate {

    func load() {
        demo = .carryPosition
        
        demoFeatures = param.node.characteristics.features(with: Demo.carryPosition.features)
        
        view.configureView()
    }
    
    func updateCarryPositionUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<CarryPositionData>,
           let data = sample.data {
            if let position = data.position.value {
                updateUIBasedOnPosition(position)
            }
        }
    }

    private func updateUIBasedOnPosition(_ position: CarryPositionType) {
        if let current = mCurrentPosition{
            view.mPositionToImage[current]?.alpha = CarryPositionPresenter.DEFAULT_ALPHA
        }
        view.mPositionToImage[position]?.alpha = CarryPositionPresenter.SELECTED_ALPHA
        mCurrentPosition = position
    }
    
}
