//
//  BlueVoiceDelegate.swift
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

protocol BlueVoiceDelegate: AnyObject {

    func load()

    func update(with feature: Feature, sample: AnyFeatureSample?)

    func startAudioPlayer()

    func mute(_ value: Bool)

    func enableBeamForming(_ value: Bool)

}
