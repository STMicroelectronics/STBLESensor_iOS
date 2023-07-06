//
//  BeamFormingView.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import CorePlot

final class BeamFormingView: UIView {

    @IBOutlet weak var mBoardImage: UIImageView!
    
    @IBOutlet weak var mLeftButton: UIButton!
    @IBOutlet weak var mRightButton: UIButton!
    @IBOutlet weak var mTopButton: UIButton!
    @IBOutlet weak var mBottomButton: UIButton!
    @IBOutlet weak var mBottomLeftButton: UIButton!
    @IBOutlet weak var mBottomRightButton: UIButton!
    @IBOutlet weak var mTopRightButton: UIButton!
    @IBOutlet weak var mTopLeftButton: UIButton!
    
    @IBOutlet weak var mGraphView: CPTGraphHostingView!
}
