//
//  HSDMotorControlPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

open class HSDMotorControlPresenter: HSDPnpLPresenter {

    weak var delegate: HSDLogIsRunningDelegate?
    
    open override func handleUpdate(from feature: PnPLFeature) {
        super.handleUpdate(from: feature)
        
        if let status = logControllerResponse?.status, !status {
            delegate?.isLogRunning(isRunning: false)
        } else {
            delegate?.isLogRunning(isRunning: true)
        }
    }
}
