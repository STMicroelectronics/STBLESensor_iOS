//
//  CompassViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 07/10/2026.
//

import Foundation
import STBlueSDK
import STCore

extension String {
    func decodeCalibrationStatus() -> AutoConfigurationStatus {
        let prefix = "magnCalibStatus "
        Logger.log(level: .debug, category: "", text: "received text: \(self)")
        guard self.hasPrefix(prefix) else { return .notConfigured }
        
        let retValue: AutoConfigurationStatus =
        if let percentageNum = Int(self.dropFirst(prefix.count)) {
            if(percentageNum<100) {
                .notConfigured
            } else {
                .configured
            }
        } else {
            .notConfigured
        }
        return retValue
    }
}

class CompassDemoViewModel: ObservableObject {
    
    @Published var angle: Float = 0.0
    @Published var orientation: Orientation = .north
    
    @Published var calibrationStatus: AutoConfigurationStatus = .notConfigured
    
    @Published var isPresentingCalibrationView = false
    
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    func sendCommandOnDebugConsole(_ commandText: String) {
        BlueManager.shared.sendMessageWithoutQueueNoCallBack(
            commandText,
            to: node
        )
    }
    
    
    func evaluateEvent(_ sample: FeatureSample<CompassData>) {
        
        guard let angle = sample.data?.angle.value else {return }
        guard let orientation = sample.data?.orientation else {return }
        
        
        self.angle = angle
        self.orientation = orientation
    }
    
    func evaluateEvent(_ sample: FeatureSample<EulerAngleData>) {
        
        guard let angle = sample.data?.angleValue else {return }
        guard let orientation = sample.data?.orientation else {return }
        
        
        self.angle = angle
        self.orientation = orientation
    }
    
}
