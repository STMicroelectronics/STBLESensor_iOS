//
//  LevelDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 15/10/2026.
//

import Foundation
import STBlueSDK

class LevelDemoViewModel: ObservableObject {
    @Published var roll: Float = 0.0
    @Published var pitch: Float = 0.0
    
    func evaluateSample(_ sample: FeatureSample<EulerAngleData>) {
        
        guard let roll = sample.data?.roll.value, let pitch = sample.data?.pitch.value else {return}
        
        self.roll = roll
        self.pitch = pitch
    }
}
