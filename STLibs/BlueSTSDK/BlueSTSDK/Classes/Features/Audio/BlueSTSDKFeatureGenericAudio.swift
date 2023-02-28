//
//  BlueSTSDKFeatureAudioConf.swift
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 03/10/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

/// feature that doesn't use the first 2 bytes as timestamp, and avoid to notify
/// the delegate using a parallel queue
public class BlueSTSDKFeatureGenericAudio : BlueSTSDKDeviceTimestampFeature {
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node)
    }
    
    public override init(whitNode node: BlueSTSDKNode, name: String) {
        super.init(whitNode: node, name: name)
    }
    
    override public func notifyUpdate(with sample: BlueSTSDKFeatureSample?) {
        guard let s = sample else {
            return
        }
        for delegate in self.featureDelegates{
            (delegate as? BlueSTSDKFeatureDelegate)?.didUpdate(self, sample: s)
        }
    }
}
