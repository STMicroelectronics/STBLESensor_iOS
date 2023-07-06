//
//  AudioSourceLocalizationView.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

final class AudioSourceLocalizationView: UIView {
    @IBOutlet weak var mBoardImage: UIImageView!
    @IBOutlet weak var mNeedleImage: UIImageView!
    @IBOutlet weak var mDirectionLabel: UILabel!
    @IBOutlet weak var sensitivitySwitch: UISwitch!
}
