//
//  PedometerDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//

import Foundation
import STBlueSDK

class PedometerDemoViewModel: ObservableObject {
    @Published var steps: UInt32 = 0
    @Published var frequency: UInt16 = 0
    
    func evaluateSample(_ sample: FeatureSample<PedometerData>) {
        let steps = sample.data?.steps.value ?? 0
        self.steps = steps
        
        let frequency = sample.data?.frequency.value ?? 0
        self.frequency = frequency
    }
}
