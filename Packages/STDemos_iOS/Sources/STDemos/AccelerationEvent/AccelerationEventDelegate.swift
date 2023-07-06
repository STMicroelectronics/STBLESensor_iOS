//
//  AccelerationEventDelegate.swift
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

protocol AccelerationEventDelegate: AnyObject {

    func load()

    func updateAccEventUI(with sample: AnyFeatureSample?)
    
    func getSupportedEvents() -> [AccelerationEventCommand]?
    
    func getDefaultEvent() -> AccelerationEventCommand

    func updateRunningAccelerationEvent(_ event: AccelerationEventCommand)
    
    func changeAccelerationEvent()

}
