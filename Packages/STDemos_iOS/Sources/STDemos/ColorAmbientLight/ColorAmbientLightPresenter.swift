//
//  ColorAmbientLightPresenter.swift
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

final class ColorAmbientLightPresenter: DemoPresenter<ColorAmbientLightViewController> {
    public let DATA_MAX_LUX: Int = 400000
    public let DATA_MIN_LUX: Int = 0
    
    public let DATA_MAX_UV_INDEX: Int = 12
    public let DATA_MIN_UV_INDEX: Int = 0
    
    public let DATA_MAX_CCT: Int = 20000
    public let DATA_MIN_CCT: Int = 0
}

// MARK: - ColorAmbientLightViewControllerDelegate
extension ColorAmbientLightPresenter: ColorAmbientLightDelegate {

    func load() {
        
        demo = .colorAmbientLight
        
        demoFeatures = param.node.characteristics.features(with: Demo.colorAmbientLight.features)
        
        view.configureView()
    }

    func updateColorAmbientLightUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<ColorAmbientLightData>,
           let data = sample.data {
            
            if let lux = data.lux.value {
                view.containerLuxView.isHidden = false
                view.luxView.title.text = "Illuminance"
                view.luxView.value.text = "\(lux)"
                let luxProgress = Float(Float(lux)/Float(DATA_MAX_LUX))
                view.luxView.progress.setProgress(luxProgress, animated: true)
                view.luxView.unit.text = "Lux"
                view.luxView.min.text = "\(data.lux.min ?? 0)"
                view.luxView.max.text = "\(data.lux.max ?? 4000)"
            }
            
            if let cct = data.cct.value {
                view.containerCCTView.isHidden = false
                view.cctView.title.text = "Correlated color temperature"
                view.cctView.value.text = "\(cct)"
                let cctProgress = Float(Float(cct)/Float(DATA_MAX_CCT))
                view.cctView.progress.setProgress(cctProgress, animated: true)
                view.cctView.unit.text = "CCT"
                view.cctView.min.text = "\(data.cct.min ?? 0)"
                view.cctView.max.text = "\(data.cct.max ?? 4000)"
            }
            
            if let uvIndex = data.uvIndex.value {
                view.containerUVIndexView.isHidden = false
                view.uvIndexView.title.text = "Intensity UV radiation"
                view.uvIndexView.value.text = "\(uvIndex)"
                let uvIndexProgress = Float(Float(uvIndex)/Float(DATA_MAX_UV_INDEX))
                view.uvIndexView.progress.setProgress(uvIndexProgress, animated: true)
                view.uvIndexView.unit.text = "UV Index"
                view.uvIndexView.min.text = "\(data.uvIndex.min ?? 0)"
                view.uvIndexView.max.text = "\(data.uvIndex.max ?? 12)"
            }
        }
    }
    
}
