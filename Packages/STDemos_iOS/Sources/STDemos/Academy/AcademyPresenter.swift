//
//  AcademyPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class AcademyPresenter: DemoPresenter<AcademyViewController> {

}

// MARK: - EventCounterViewControllerDelegate
extension AcademyPresenter: AcademyDelegate {
    func enableNotification() {
        if let accFeature = param.node.characteristics.first(with: AccelerationFeature.self) as? AccelerationFeature {
            BlueManager.shared.enableNotifications(for: param.node, feature: accFeature)
        }
    }
    
    func disableNotification() {
        if let accFeature = param.node.characteristics.first(with: AccelerationFeature.self) as? AccelerationFeature {
            BlueManager.shared.disableNotifications(for: param.node, feature: accFeature)
        }
    }
    
    func newAccSample(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<AccelerationData>,
           let data = sample.data {
            guard let xValue = data.accelerationX.value else { return }
            guard let yValue = data.accelerationY.value else { return }
            guard let zValue = data.accelerationZ.value else { return }
            
            view.xLabel.text = "X: \(xValue)"
            view.yLabel.text = "Y: \(yValue)"
            view.zLabel.text = "Z: \(zValue)"
            
            estimateBopxProPosition(x: xValue, y: yValue, z: zValue)
        }
    }
    
    func estimateBopxProPosition(x: Float, y: Float, z: Float){
        if x < 100.0 && y < 100.0 && z > 900.0 {
            view.imageView.image = ImageLayout.image(with: "PRO_top", in: STUI.bundle)
            view.estimateLabel.text = "Estimate position: TOP"
        } else if x < 100.0 && y < 100.0 && z > -900.0 {
            view.imageView.image = ImageLayout.image(with: "PRO_bottom", in: STUI.bundle)
            view.estimateLabel.text = "Estimate position: BOTTOM"
        }
    }

    func load() {
        
        view.configureView()
    }
    
}
