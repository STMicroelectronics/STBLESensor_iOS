//
//  MotionIntensityDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//



import Foundation
import STBlueSDK

class MotionIntensityDemoViewModel: ObservableObject {
    @Published var motionIntensity: UInt8 = 0
    
    func evaluateSample(_ sample: FeatureSample<MotionIntensityData>) {
        let motionIntensity = sample.data?.motionIntensity.value ?? 0
        self.motionIntensity = motionIntensity
    }
}
