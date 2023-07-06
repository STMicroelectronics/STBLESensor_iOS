//
//  MEMSSensorFusionPresenter.swift
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
import SceneKit
import Toast

final class MEMSSensorFusionPresenter: DemoPresenter<MEMSSensorFusionViewController> {
    var status: AutoConfigurationStatus = .notConfigured
    
    private static let CUBE_DEFAULT_SCALE = Float(1.5)
    private static let MAX_PROXIMITY_VALUE = Float(255)
    
    private static let DISTANCE_OUT_OF_RANGE: String = {
        return NSLocalizedString("Distance: Out of range", tableName: nil, bundle: .module,
                                 value: "Distance: Out of range", comment: "")
    }()
    
    private static let DISTANCE_FORMAT:String = {
        return NSLocalizedString("Distance: %.0f mm", tableName: nil, bundle: .module,
                                 value: "Distance: %.0f mm", comment: "")
    }()
}

// MARK: - MEMSSensorFusionViewControllerDelegate
extension MEMSSensorFusionPresenter: MEMSSensorFusionDelegate {

    func load() {
        demo = .memsSensorFusion

        demoFeatures = param.node.characteristics.features(with: Demo.memsSensorFusion.features)
        
        startCalibration()
        
        view.configureView()
        
        TextLayout.info.apply(to: view.mainView.proximityText)
        view.mainView.proximityText.textAlignment = .center
        
        demoFeatures.forEach { feature in
            if((feature as? ProximityFeature) != nil) {
                view.mainView.proxymityBtn.alpha = 1.0
                view.mainView.proxymityBtn.isUserInteractionEnabled = true
                view.mainView.proximityText.isHidden = false
            }
        }
    }
    
    func startCalibration() {
        if let feature = param.node.characteristics.features(with: Demo.memsSensorFusion.features).first {
            demoFeatures.append(feature)

            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: AutoConfigurationCommand.start,
                    data: AutoConfigurationCommand.start.payload
                ),
                to: param.node,
                feature: feature
            )
        }
    }
    
    func startReset() {
        view.showRestDialog(node: param.node.type)
    }
    
    func startStopProxymity () {
        if(view.proximityIsEnabled) {
            disableProximity()
            view.setCubeScaleFactor(MEMSSensorFusionPresenter.CUBE_DEFAULT_SCALE)
            view.proximityIsEnabled = false
        } else {
            enableProximity()
            view.proximityIsEnabled = true
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

    func updateSensorFusionValue(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<SensorFusionData>,
           let data = sample.data {
            updateCubeRotation(with: data)
        } else if let sample = sample as? FeatureSample<SensorFusionCompactData>,
                  let data = sample.data {
            data.samples.forEach { sample in
                updateCubeRotation(with: sample)
            }
        } else if let sample = sample as? FeatureSample<AccelerationEventData>,
                  let data = sample.data {
            if let event = data.event.value {
                if event == .freeFall {
                    self.view.view.makeToast("Free Fall Detected!", duration: 1.0)
                }
            }
        } else if let sample = sample as? FeatureSample<ProximityData>,
                  let data = sample.data {
            if let distance = data.distance.value {
                if(distance != ProximityData.outOfrange){
                    let scaleDistance = Float.minimum(Float(distance), MEMSSensorFusionPresenter.MAX_PROXIMITY_VALUE)
                    let scale = MEMSSensorFusionPresenter.CUBE_DEFAULT_SCALE * (scaleDistance / MEMSSensorFusionPresenter.MAX_PROXIMITY_VALUE)
                    view.setCubeScaleFactor(scale)
                    self.view.mainView.proximityText.text = String(format: MEMSSensorFusionPresenter.DISTANCE_FORMAT, distance)
                } else {
                    view.setCubeScaleFactor(MEMSSensorFusionPresenter.CUBE_DEFAULT_SCALE)
                    view.mainView.proximityText.text = String(format: MEMSSensorFusionPresenter.DISTANCE_OUT_OF_RANGE)
                }
            }
        }
    }
    
    private func updateCubeRotation(with sample: SensorFusionData) {
        var glkQuaternion = GLKQuaternion()
        
        if let quaternionI = sample.quaternionI.value {
            if let quaternionJ = sample.quaternionJ.value {
                if let quaternionK = sample.quaternionK.value {
                    if let quaternionS = sample.quaternionS.value {
                        glkQuaternion.z = quaternionI
                        glkQuaternion.y = quaternionJ
                        glkQuaternion.x = quaternionK
                        glkQuaternion.w = quaternionS
                    }
                }
            }
        }
        
        if(view.resetPosition){
            view.resetPosition = false
            resetCubePosition(quaternion: glkQuaternion)
        }
        
        glkQuaternion = GLKQuaternionMultiply(view.mResetQuat, glkQuaternion)

        let rot = SCNQuaternion(x: glkQuaternion.x, y: glkQuaternion.y, z: glkQuaternion.z, w: glkQuaternion.w)
        DispatchQueue.main.async {
            self.view.m3DCube?.orientation = rot
        }
    }
    
    private func resetCubePosition(quaternion glkQuaternion: GLKQuaternion) {
        view.mResetQuat = GLKQuaternionInvert(glkQuaternion)
    }
    
    private func enableProximity() {
        view.mainView.proximityText.isHidden = false
    }
    
    private func disableProximity() {
        view.mainView.proximityText.isHidden = true
    }
}
