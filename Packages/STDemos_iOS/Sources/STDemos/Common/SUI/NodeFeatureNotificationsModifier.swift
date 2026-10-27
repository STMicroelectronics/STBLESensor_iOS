//
//  NodeFeatureNotificationsModifier.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK

/// Enables BLE notifications for a demo's features while the view is on screen,
/// mirroring what the legacy `DemoPresenter` base class did via `demoFeatures` +
/// `viewWillAppear`/`viewWillDisappear`. Apply this to every migrated demo's root view.
struct NodeFeatureNotificationsModifier: ViewModifier {
    let node: Node
    let demo: Demo
    let automaticNotification: Bool
    
    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if(automaticNotification) {
                    let features = node.characteristics.features(with: demo.features)
                    BlueManager.shared.enableNotifications(for: node, features: features)
                }
            }
            .onDisappear {
                if(automaticNotification) {
                    let features = node.characteristics.features(with: demo.features)
                    BlueManager.shared.disableNotifications(for: node, features: features)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if(automaticNotification) {
                    let features = node.characteristics.features(with: demo.features)
                    switch newPhase {
                    case .active:
                        BlueManager.shared.enableNotifications(for: node, features: features)
                    case .background, .inactive:
                        BlueManager.shared.disableNotifications(for: node, features: features)
                    @unknown default:
                        break
                    }
                }
            }
    }
}
extension View {
    func enablingNotifications(for node: Node, demo: Demo, automaticNotification: Bool) -> some View {
        modifier(NodeFeatureNotificationsModifier(node: node, demo: demo, automaticNotification: automaticNotification))
    }
}
