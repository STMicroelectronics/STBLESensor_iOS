//
//  AssetTrackingEventPresenter.swift
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

final class AssetTrackingEventPresenter: DemoPresenter<AssetTrackingEventViewController> {
}

// MARK: - CarryPositionViewControllerDelegate
extension AssetTrackingEventPresenter: AssetTrackingEventDelegate {

    func load() {
        demo = .assetTrackingEvent
        
        demoFeatures = param.node.characteristics.features(with: Demo.assetTrackingEvent.features)

        view.configureView()
        
        view.presentSwiftUIView(AssetTrackingEventView(node: param.node))
    }
    
}
