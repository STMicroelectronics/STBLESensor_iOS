//
//  EventDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 16/10/2026.
//

import Foundation
import STBlueSDK

class EventCounterDemoViewModel: ObservableObject {
    @Published var counter: UInt32 = 0

    func evaluateSample(_ sample: FeatureSample<EventCounterData>) {
        guard let counter = sample.data?.counter.value else {return }
        self.counter = counter
    }
}
