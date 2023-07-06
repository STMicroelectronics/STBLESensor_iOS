//
//  MotionIntensityPresenter.swift
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
import GLKit

final class MotionIntensityPresenter: DemoPresenter<MotionIntensityViewController> {
    private static let ANIMATION_DURATION_S = TimeInterval(0.3);
    
    private static let NEEDLE_OFFSET_DEG = [
        GLKMathDegreesToRadians(-135),
        GLKMathDegreesToRadians(-108),
        GLKMathDegreesToRadians( -81),
        GLKMathDegreesToRadians( -54),
        GLKMathDegreesToRadians( -27),
        GLKMathDegreesToRadians(   0),
        GLKMathDegreesToRadians(  27),
        GLKMathDegreesToRadians(  54),
        GLKMathDegreesToRadians(  81),
        GLKMathDegreesToRadians( 108),
        GLKMathDegreesToRadians( 135),
    ]
    
    private static let INTENSITY_FORMAT:String = {
        return NSLocalizedString("The Motion intensity value is: %d",
                                 tableName: nil,
                                 bundle: .module,
                                 value: "The Motion intensity value is: %d",
                                 comment: "")
        
    }()
}

// MARK: - MotionIntensityViewControllerDelegate
extension MotionIntensityPresenter: MotionIntensityDelegate {

    func load() {
        
        demo = .motionIntensity
        
        demoFeatures = param.node.characteristics.features(with: Demo.motionIntensity.features)
        
        view.configureView()
    }
    
    func updateMotionIntensityUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<MotionIntensityData>,
           let data = sample.data {
            if let intensity = data.motionIntensity.value {
                if intensity >= 0 && intensity < MotionIntensityPresenter.NEEDLE_OFFSET_DEG.count {
                    let rotationDeg = MotionIntensityPresenter.NEEDLE_OFFSET_DEG[Int(intensity)]
                    
                    view.mainView.intensityLabel.text = String(format: MotionIntensityPresenter.INTENSITY_FORMAT, intensity)
                    
                    UIView.animate(withDuration: MotionIntensityPresenter.ANIMATION_DURATION_S, animations: {
                        self.view.mainView.intensityArrow.transform = CGAffineTransform(rotationAngle: CGFloat(rotationDeg))
                    })
                }
            }
        }
    }

}
