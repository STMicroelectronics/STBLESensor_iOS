//
//  SwitchDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import Foundation
import STBlueSDK

class SwitchDemoViewModel: ObservableObject {
    
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    @Published var status: UInt8 = 0
    
    func evaluateSample(_ sample: FeatureSample<SwitchData>) {
        guard let status = sample.data?.status.value else {return}
        
        self.status = status
    }
    
    func sendSwitchTypeCommand(_ command: SwitchType) {
        if let switchFeature = node.characteristics.first(with: SwitchFeature.self) {
            
            BlueManager.shared.sendCommand(
                FeatureCommand(
                    type: command,
                    data: command.payload
                ),
                to: node,
                feature: switchFeature
            )
        }
    }
}
