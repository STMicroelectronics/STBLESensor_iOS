//
//  CloudMQTTPresenter.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import STBlueSDK
import STCore

final class CloudMQTTPresenter: DemoPresenter<CloudMQTTViewController> {
}

// MARK: - CarryPositionViewControllerDelegate
extension CloudMQTTPresenter: CloudMQTTDelegate {

    func load() {
        demo = .cloudMqtt
        
        demoFeatures = param.node.characteristics.features(with: Demo.cloudMqtt.features)
        
//        if let feature = param.node.characteristics.first(with: BatteryFeature.self) {
//            BlueManager.shared.enableNotifications(for: param.node, feature: feature)
//        }
//        
        view.configureView()
        
        view.presentSwiftUIView(CloudMQTTConfigurationView(node: param.node))
    }
    
}
