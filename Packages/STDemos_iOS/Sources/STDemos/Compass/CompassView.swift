//
//  CompassView.swift
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

final class CompassView: UIView {

    @IBOutlet weak var compassImageView: UIImageView!
    @IBOutlet weak var needleImageView: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var calibrationImageView: UIImageView!
    @IBOutlet weak var angleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        calibrationImageView.contentMode = .scaleAspectFit
        calibrationImageView.image = UIImage(named: "img_compass_uncalibrated")

        TextLayout.subtitle
            .alignment(.center)
            .apply(to: directionLabel)

        TextLayout.subtitle
            .alignment(.center)
            .apply(to: angleLabel)

        directionLabel.text = nil
        angleLabel.text = nil
    }
    
}
