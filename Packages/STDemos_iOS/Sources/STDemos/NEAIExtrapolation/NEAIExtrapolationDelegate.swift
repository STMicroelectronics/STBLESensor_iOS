//
//  NEAIExtrapolationDelegate.swift
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

protocol NEAIExtrapolationDelegate: AnyObject {
    
    func load()
    
    func enableNotification()
    
    func disableNotification()
    
    func expandOrHideNEAICommands()
    
    func startExtrapolation()
    
    func stopExtrapolation()
    
    func howRemoveStubMode()
    
    func updateNEAIExtrapolationUI(with sample: AnyFeatureSample?)
}
