//
//  LevelDelegate.swift
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

protocol LevelDelegate: AnyObject {

    func load()

    func changeLevelMeasure()
    
    func setZero()
    
    func resetZero()
    
    func updateLevelUI(with sample: AnyFeatureSample?)
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView)
}
