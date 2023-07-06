//
//  BabyCryingView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STBlueSDK

class BabyCryingView : UIView, BaseAudioClassView{
    
    @IBOutlet weak var cryingImage: UIImageView!
    @IBOutlet weak var notCryingImage: UIImageView!
        
    lazy var activityToImage: [AudioClass : UIImageView] = {
        return [
            .unknown : notCryingImage,
            .babyIsCrying: cryingImage
        ]
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
