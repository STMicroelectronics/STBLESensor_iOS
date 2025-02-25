//
//  TextualMonitorDelegate.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK

protocol TextualMonitorDelegate: AnyObject {
    
    func load()
    
    func selectFeature()
    
    func startStopFeature()
    
    func stopFeatureAtClose()
    
    func updateFeatureValue(sample: String?)
    
    func updateFeatureValueGP(sample: AnyFeatureSample?, formats: [BleCharacteristicFormat]?)
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature)
    
    func updateFeatureValueRawPnPLControlled(with sample: AnyFeatureSample?, and feature: Feature)
}
