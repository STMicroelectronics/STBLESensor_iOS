//
//  ActivityRecognitionDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 23/10/2026.
//

import Foundation
import STBlueSDK

class ActivityRecognitionDemoViewModel: ObservableObject {
    @Published var activity: ActivityType? = nil
    @Published var algorithmId: UInt8? = nil
    
    func evaluateSample(_ sample: FeatureSample<ActivityData>) {
        
        let activity = sample.data?.activity.value
        
        self.activity = activity
        
        guard let algorithmId = sample.data?.algorithmId.value else { return }
        self.algorithmId = algorithmId
    }
}
