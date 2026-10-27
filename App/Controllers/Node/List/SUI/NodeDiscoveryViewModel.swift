//
//  NodeDiscoveryViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
@preconcurrency import STBlueSDK
import STCore

class NodeDiscoveryViewModel: NSObject, ObservableObject {
    @Published var connectingNode: Node?
    @Published var isConnecting = false
    @Published var selectedNode: Node?
    @Published var connectionErrorMessage: String?

    @Published private(set) var discoveredNodes: [Node] = []
    @Published var isDiscovering: Bool = false
    @Published var minRSSI: Int = -100

    private let discoveryTimeout = 10_000
    private let connectionTimeout: UInt64 = 10_000_000_000
    private let favoritesService: FavoritesService? = Resolver.shared.resolve()
    private var connectionTimeoutTask: Task<Void, Never>?

    override init() {
        super.init()
        BlueManager.shared.addDelegate(self)
    }

    deinit {
        connectionTimeoutTask?.cancel()
        BlueManager.shared.removeDelegate(self)
    }

    var filteredNodes: [Node] {
        discoveredNodes
            .filter { ($0.rssi ?? 0) >= minRSSI }
            .stablePartitioned { isFavorite($0) }
    }

    func updateRSSIFilter(_ value: Int) {
        minRSSI = value
    }

    func startDiscovery() {
        BlueManager.shared.resetDiscovery()
        BlueManager.shared.discoveryStart(discoveryTimeout)
    }

    func stopDiscovery() {
        BlueManager.shared.discoveryStop()
    }

    func toggleDiscovery() {
        if isDiscovering {
            stopDiscovery()
        } else {
            startDiscovery()
        }
    }
    func connect(to node: Node) {
        cancelConnectionAttempt()
        connectionErrorMessage = nil
        connectingNode = node
        isConnecting = true
        startConnectionTimeout(for: node)
        stopDiscovery()
        BlueManager.shared.connect(node)
    }

    func cancelConnectionAttempt() {
        connectionTimeoutTask?.cancel()
        connectionTimeoutTask = nil
        isConnecting = false
        connectingNode = nil
    }

    func dismissConnectionError() {
        connectionErrorMessage = nil
    }

    func isFavorite(_ node: Node) -> Bool {
        favoritesService?.isFavorite(node: node) ?? false
    }

    func toggleFavorite(_ node: Node) {
        guard let service = favoritesService else { return }

        if service.isFavorite(node: node) {
            service.removeNodeFromFavorites(node: node)
        } else {
            service.addNodeToFavorites(node: node)
        }

        objectWillChange.send()
    }

    private func startConnectionTimeout(for node: Node) {
        connectionTimeoutTask?.cancel()

        connectionTimeoutTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: self?.connectionTimeout ?? 0)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self, self.connectingNode == node else { return }

                self.connectionTimeoutTask = nil
                self.isConnecting = false
                self.connectingNode = nil
                self.connectionErrorMessage = "Couldn't connect to the node. Please refresh and try again."
            }
        }
    }
}

extension NodeDiscoveryViewModel: BlueDelegate {
    func manager(_ manager: STBlueSDK.BlueManager, didDiscover node: STBlueSDK.Node) {
        DispatchQueue.main.async { self.discoveredNodes = BlueManager.shared.discoveredNodes }
    }

    func manager(_ manager: STBlueSDK.BlueManager, didChangeStateFor node: STBlueSDK.Node) {
        guard node == connectingNode else { return }

        DispatchQueue.main.async {
            guard node == self.connectingNode else { return }

            self.connectionTimeoutTask?.cancel()
            self.connectionTimeoutTask = nil
            self.isConnecting = false
            self.connectingNode = nil

            if node.isConnected {
                self.selectedNode = node
            }
        }
    }

    func manager(_ manager: STBlueSDK.BlueManager,
                 didUpdateValueFor node: STBlueSDK.Node,
                 feature: any STBlueSDK.Feature,
                 sample: (any STBlueSDK.AnyFeatureSample)?) {}

    func manager(_ manager: STBlueSDK.BlueManager,
                 didReceiveCommandResponseFor node: STBlueSDK.Node,
                 feature: any STBlueSDK.Feature,
                 response: any STBlueSDK.FeatureCommandResponse) {}

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {
        DispatchQueue.main.async { self.isDiscovering = isDiscovering }
    }
    
    func manger(_ service: BlueManager, receivedDebugConsoleDataFor node: Node, data: Data) {}

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {
        DispatchQueue.main.async { self.discoveredNodes = BlueManager.shared.discoveredNodes }
    }
}

extension Array {
    func stablePartitioned(
        by belongsInFirstPartition: (Element) -> Bool
    ) -> [Element] {

        let first = filter(belongsInFirstPartition)
        let second = filter { !belongsInFirstPartition($0) }

        return first + second
    }
}
