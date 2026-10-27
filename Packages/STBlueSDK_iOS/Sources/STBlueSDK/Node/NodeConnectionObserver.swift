//
//  NodeConnectionObserver.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

/// Observes disconnection of a single `Node` and notifies a callback on the main actor.
public final class NodeConnectionObserver: NSObject, BlueDelegate, @unchecked Sendable {

    private let node: Node
    private let onDisconnected: @MainActor () -> Void
    private var isObserving = false

    public init(currentNode: Node, onNodeDisconnected: @escaping @MainActor () -> Void) {
        self.node = currentNode
        self.onDisconnected = onNodeDisconnected
    }

    @MainActor
    public func start() {
        guard !isObserving else { return }
        isObserving = true
        BlueManager.shared.addDelegate(self)
    }

    @MainActor
    public func stop() {
        guard isObserving else { return }
        isObserving = false
        BlueManager.shared.removeDelegate(self)
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
    }

    nonisolated public func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    nonisolated public func manager(_ manager: BlueManager, didDiscover node: Node) {}
    nonisolated public func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    nonisolated public func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {}
    nonisolated public func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    
    nonisolated public func manger(_ service: BlueManager, receivedDebugConsoleDataFor node: Node, data: Data) {}

    nonisolated public func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        guard node.tag == self.node.tag, !node.isConnected else { return }
        let callback = onDisconnected
        Task { @MainActor in
            callback()
        }
    }
}
