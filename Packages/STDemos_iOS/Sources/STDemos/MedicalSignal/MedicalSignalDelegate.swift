//
//  MedicalSignalDelegate.swift
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

protocol MedicalSignalDelegate: AnyObject {

    func load()
    
    func update16BitPlot(with sample: AnyFeatureSample?)
    
    func update24BitPlot(with sample: AnyFeatureSample?)
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature)
    
    func updateFeatureValueRawPnPLControlled(with sample: AnyFeatureSample?, and feature: Feature)
    
    func startStop16BitPlotting()
    
    func startStop24BitPlotting()
    
    func resetChartsZoom()
    
    func disableAllNotifications()
}
