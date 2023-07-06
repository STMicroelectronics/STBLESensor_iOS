//
//  CompassPresenter.swift
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

final class CompassPresenter: DemoPresenter<CompassViewController> {
    var status: AutoConfigurationStatus = .notConfigured
}

// MARK: - CompassDelegate
extension CompassPresenter: CompassDelegate {

    func load() {

        demo = .compass

        demoFeatures = param.node.characteristics.features(with: Demo.compass.features)
        
        view.title = demo?.title

        startCalibration()

        view.configureView()
    }

    func startCalibration() {
        if let feature = param.node.characteristics.features(with: Demo.compass.features).first {
            demoFeatures.append(feature)

            BlueManager.shared.sendCommand(FeatureCommand(type: AutoConfigurationCommand.start,
                                                          data: AutoConfigurationCommand.start.payload),
                                           to: param.node,
                                           feature: feature)
        }
    }

    func updateCalibration(with status: AutoConfigurationStatus) {

        self.status = status

        if status == .configured {
            view.showCalibrationDone()
        } else {
            view.showCalibrationIsNeeded()
        }
    }

    func updateCompassValue(with sample: AnyFeatureSample?) {

        /*if status == .notConfigured {
            view.mainView.directionLabel.text = nil
            view.mainView.angleLabel.text = nil
            view.mainView.needleImageView.transform = CGAffineTransform(rotationAngle: 0.0)
            return
        }*/

        if let sample = sample as? FeatureSample<CompassData>,
           let data = sample.data {
            view.updateCompass(with: data.angleValue, orientation: data.orientation)
        } else if let sample = sample as? FeatureSample<EulerAngleData>,
                  let data = sample.data {
            view.updateCompass(with: data.angleValue, orientation: data.orientation)
        }
    }

}
