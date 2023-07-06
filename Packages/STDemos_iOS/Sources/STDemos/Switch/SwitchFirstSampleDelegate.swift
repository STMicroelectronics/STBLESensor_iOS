//
//  SwitchFirstSampleDelegate.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

class SwitchFirstSampleDelegate: BlueDelegate {
    
    public typealias SwitchSampleCompletion = (_ sample: SwitchData?) -> Void
    private let completion: SwitchSampleCompletion
    
    init(completion: @escaping ((SwitchData?) -> ()) ){
        self.completion = completion
    }

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        if let switchFeature = feature as? SwitchFeature {
            manager.removeDelegate(self)
            
            guard let switchSampleData = switchFeature.sample?.data else {
                completion(nil)
                return
            }
            
            completion(switchSampleData)
        }
    }
}
