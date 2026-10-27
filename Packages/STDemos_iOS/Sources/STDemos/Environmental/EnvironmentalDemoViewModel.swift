//
//  EnvironmentalViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 06/10/2026.
//


import Foundation
import STBlueSDK

class EnvironmentalDemoViewModel: ObservableObject {
    @Published var hasHumidity: Bool = false
    @Published var humidity: Double? = nil
    
    @Published var hasPressure: Bool = false
    @Published var pressure: Double? = nil
    
    @Published var hasTemperature: Bool = false
    @Published var temperature: Double? = nil
    
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    
    func evaluateEvent(_ sample: FeatureSample<PressureData>) {
        
        hasPressure = true
        guard let pressure = sample.data?.pressure.value else {return }
        
        self.pressure = Double(pressure)
    }
    
    func evaluateEvent(_ sample: FeatureSample<HumidityData>) {
        
        hasHumidity = true
        guard let humidity = sample.data?.humidity.value else {return }
        
        self.humidity = Double(humidity)
    }
    
    func evaluateEvent(_ sample: FeatureSample<TemperatureData>) {
        
        hasTemperature = true
        guard let temperature = sample.data?.temperature.value else {return }
        
        self.temperature = Double(temperature)
    }
    
    func readPressureFeature() {
        if let feature = node.characteristics.first(with: PressureFeature.self) {
            BlueManager.shared.read(feature: feature, for: node)
        }
    }
    
    func readHumidityFeature() {
        if let feature = node.characteristics.first(with: HumidityFeature.self) {
            BlueManager.shared.read(feature: feature, for: node)
        }
    }
    
    func readTemperatureFeature() {
        if let feature = node.characteristics.first(with: TemperatureFeature.self) {
            BlueManager.shared.read(feature: feature, for: node)
        }
    }
}
