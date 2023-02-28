//
//  Discoverer.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation
import BlueSTSDK

typealias DiscoverUpdateBlock = ([BlueSTSDKNode], Bool) -> Void

class Discoverer: NSObject {
        
    private var updateBlock: DiscoverUpdateBlock?
    
    func startDiscoveringNodes(_ updateBlock: (DiscoverUpdateBlock?)) {
        self.updateBlock = updateBlock
        
        BlueSTSDKManager.sharedInstance.addDelegate(self)
        BlueSTSDKManager.sharedInstance.resetDiscovery(true)
        BlueSTSDKManager.sharedInstance.discoveryStart(10_000)
    }
    
    func stopDiscoveringNodes() {
        BlueSTSDKManager.sharedInstance.removeDelegate(self)
        BlueSTSDKManager.sharedInstance.discoveryStop()
    }
}

private extension Discoverer {
    func callUpdateBlockIfNeeded(success: Bool) {
        guard let updateBlock = self.updateBlock else { return }
        updateBlock(BlueSTSDKManager.sharedInstance.nodes, success)
    }
}

extension Discoverer: BlueSTSDKManagerDelegate {
    func manager(_ manager: BlueSTSDKManager, didDiscoverNode node: BlueSTSDKNode) {
        
        DispatchQueue.main.async { [weak self] in
            self?.callUpdateBlockIfNeeded(success: true)
        }
    }
    
    func manager(_ manager: BlueSTSDKManager, didChangeDiscovery enable: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            if enable == false {
                if let delegate = self {
                    BlueSTSDKManager.sharedInstance.removeDelegate(delegate)
                    self?.callUpdateBlockIfNeeded(success: false)
                }
            }
        }
    }
}
