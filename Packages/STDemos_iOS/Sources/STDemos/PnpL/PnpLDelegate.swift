//
//  PnpLDelegate.swift
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
import STUI

public protocol PnpLDelegate: DemoDelegate {
    
    func removeFirstQueueAndEventuallySend()
    
    func load()

    //var disableNotificationOnDisappear: Bool { get set }

    func update(with feature: PnPLFeature)

}
