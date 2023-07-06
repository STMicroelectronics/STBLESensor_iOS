//
//  BeamFormingDelegate.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK

protocol BeamFormingDelegate: AnyObject {

    func load()
    
    func startAudioPlayer()
    
    func changeDirection(_ direction: BeamFormingDirection)
    
    func updateBeamformingUI(with feature: Feature, with sample: AnyFeatureSample?)
}
