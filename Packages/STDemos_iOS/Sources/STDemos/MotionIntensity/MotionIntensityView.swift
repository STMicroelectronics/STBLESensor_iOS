//
//  MotionIntensityView.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

final class MotionIntensityView: UIView {
    @IBOutlet weak var motionIntensityDemoTitle: UILabel!
    @IBOutlet weak var intensityArrow: UIImageView!
    @IBOutlet weak var intensityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TextLayout.info.apply(to: motionIntensityDemoTitle)
        TextLayout.bold.apply(to: intensityLabel)
        intensityLabel.textAlignment = .center
    }
}
