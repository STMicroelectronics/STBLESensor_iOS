//
//  IotCentralFeatureListener.swift
//  W2STApp
//
//  Created by Dimitri Giani on 17/06/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

class IotCentralFeatureListener: BlueMSSubSampligFeatureDelegate {
    weak var device: IoTDevice?
    
    var didUpdateSample: (IoTDevice, BlueSTSDKFeature, BlueSTSDKFeatureSample) -> Void = { _, _, _ in }
    
    init(device: IoTDevice?) {
        self.device = device
        
        super.init()
    }
    
    override func featureHasNewUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        guard let device = device else { return }
        didUpdateSample(device, feature, sample)
    }
    
    override func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        super.didUpdate(feature, sample: sample)
    }
}
