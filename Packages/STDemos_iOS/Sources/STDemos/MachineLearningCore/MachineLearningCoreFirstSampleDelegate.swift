//
//  MachineLearningCoreFirstSampleDelegate.swift
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

class MachineLearningFirstSampleDelegate: BlueDelegate {
    
    public typealias FirstMLCSampleCompletion = (_ sample: MachineLearningCoreData?) -> Void
    private let completion: FirstMLCSampleCompletion
    
    init(completion: @escaping ((MachineLearningCoreData?) -> ()) ){
        self.completion = completion
    }

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        if let mlcFeature = feature as? MachineLearningCoreFeature {
            manager.removeDelegate(self)
            
            guard let mlcSampleData = mlcFeature.sample?.data else {
                completion(nil)
                return
            }
            
            completion(mlcSampleData)
        }
    }
}
