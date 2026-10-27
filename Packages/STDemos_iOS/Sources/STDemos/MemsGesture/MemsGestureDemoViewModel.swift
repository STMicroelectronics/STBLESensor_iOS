//
//  MemsGestureDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 23/10/2026.
//

import Foundation
import STBlueSDK

class MemsGestureDemoViewModel: ObservableObject {
    @Published var gesture: GestureType? = nil
    
    func evaluateSample(_ sample: FeatureSample<MemsGestureData>) {
        guard let gesture = sample.data?.gesture.value else {return }
        
        if gesture != .unknown {
            self.gesture = gesture
        }
    }
}
