//
//  BatteryDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 16/10/2026.
//

import Foundation
import STBlueSDK

class BatteryDemoviewModel: ObservableObject {
    @Published var rssi: Int = 0
    @Published var current: Float? = nil
    @Published var voltage: Float? = nil
    @Published var level: Float? = nil
    @Published var status: BatteryStatus = .unknown
    
    func evaluateSample(_ sample: FeatureSample<BatteryData>) {
        self.current = sample.data?.current.value
        self.voltage = sample.data?.voltage.value
        self.level = sample.data?.level.value
        self.status = sample.data?.status ?? .unknown
    }
    
    func updateRSSI(with rssi: Int) {
        DispatchQueue.main.async {
            self.rssi = rssi
        }
    }
}
