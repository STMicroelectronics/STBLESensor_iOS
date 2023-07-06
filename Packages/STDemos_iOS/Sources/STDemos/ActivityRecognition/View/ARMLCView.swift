//
//  File.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import Foundation
import STBlueSDK

class ARMLCView : UIView, ARBaseView {
    
    @IBOutlet weak var standingImage: UIImageView!
    @IBOutlet weak var walkingImage: UIImageView!
    @IBOutlet weak var joggingImage: UIImageView!
    @IBOutlet weak var bikingImage: UIImageView!
    @IBOutlet weak var drivingImage: UIImageView!
    
    lazy var activityToImage: [ActivityType : UIImageView] = {
        return [
            .standing : standingImage,
            .walking : walkingImage,
            .jogging : joggingImage,
            .biking : bikingImage,
            .driving : drivingImage
        ]
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
