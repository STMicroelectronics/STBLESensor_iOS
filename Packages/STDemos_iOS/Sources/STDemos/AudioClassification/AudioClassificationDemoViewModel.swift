//
//  AudioClassificationDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//

import Foundation
import STBlueSDK

class AudioClassificationDemoViewModel: ObservableObject {
    @Published var algorithm: UInt8? = nil
    @Published var classifcation: AudioClass = .unknown
    
    func evaluateSample(_ sample: FeatureSample<AudioClassificationData>) {
        let algorithm = sample.data?.algorithm?.value
        self.algorithm = algorithm
        guard let classsification = sample.data?.audioClass?.value else {return }
        self.classifcation = classsification
    }
}
