//
//  MEMSSensorFusionView.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import SceneKit

final class MEMSSensorFusionView: UIView {

    @IBOutlet weak var m3DCubeView: SCNView!
    @IBOutlet weak var calibrationBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var proxymityBtn: UIButton!
    @IBOutlet weak var proximityText: UILabel!
    
}
