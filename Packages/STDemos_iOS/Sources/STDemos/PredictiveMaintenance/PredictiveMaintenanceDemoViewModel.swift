//
//  PredictiveMaintenanceDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import Foundation
import STBlueSDK

class PredictiveMaintenanceDemoViewModel: ObservableObject {
    @Published var speedStatus: ViewStatusPredictive? = nil
    @Published var accelerationStatus: ViewStatusPredictive? = nil
    @Published var frequencyStatus: ViewStatusPredictive? = nil
    
    func evaluateSample(_ sample: FeatureSample<PredictiveSpeedStatusData>) {
        
        guard let data = sample.data else { return }
        
        self.speedStatus = ViewStatusPredictive(xStatus: data.statusSpeedX.value,
                                                yStatus: data.statusSpeedY.value,
                                                zStatus: data.statusSpeedZ.value,
                                                x: PointPredictive(value: data.rmsSpeedX.value),
                                                y: PointPredictive(value: data.rmsSpeedY.value),
                                                z: PointPredictive(value: data.rmsSpeedZ.value))
    }
    
    func evaluateSample(_ sample: FeatureSample<PredictiveAccelerationStatusData>) {
        
        guard let data = sample.data else { return }
        
        self.accelerationStatus = ViewStatusPredictive(xStatus: data.statusAccX.value,
                                                       yStatus: data.statusAccY.value,
                                                       zStatus: data.statusAccZ.value,
                                                       x: PointPredictive(value: data.accelerationX.value),
                                                       y: PointPredictive(value: data.accelerationY.value),
                                                       z: PointPredictive(value: data.accelerationZ.value))
    }
    
    func evaluateSample(_ sample: FeatureSample<PredictiveFrequencyDomainStatusData>) {
        
        guard let data = sample.data else { return }
        
        self.frequencyStatus = ViewStatusPredictive(xStatus: data.statusX.value,
                                                    yStatus: data.statusY.value,
                                                    zStatus: data.statusZ.value,
                                                    x: PointPredictive(freq: data.freqX.value, value: data.valueX.value),
                                                    y: PointPredictive(freq: data.freqY.value, value: data.valueY.value),
                                                    z: PointPredictive(freq: data.freqZ.value, value: data.valueZ.value))
    }
}
