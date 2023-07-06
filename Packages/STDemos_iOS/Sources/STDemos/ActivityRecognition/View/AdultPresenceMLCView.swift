//
//  AdultPresenceMLCView.swift
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
import STUI

class AdultPresenceMLCView : UIView, ARBaseView{

    @IBOutlet weak var adultInCarImage: UIImageView!
    @IBOutlet weak var adultNotInCarImage: UIImageView!
    
    lazy var activityToImage: [ActivityType : UIImageView] = {
        return [
            .noActivity : adultNotInCarImage,
            .adultInCar : adultInCarImage
        ]
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
