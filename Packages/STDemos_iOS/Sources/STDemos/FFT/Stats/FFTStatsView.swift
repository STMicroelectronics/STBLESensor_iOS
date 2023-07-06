//
//  FFTStatsView.swift
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
import STUI

public class FFTStatsView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fftStatsTtile: UILabel!
    
    @IBOutlet weak var fftFrequencyDataInfoLabel: UILabel!
    @IBOutlet weak var fftStatsFrequencyX: UILabel!
    @IBOutlet weak var fftStatsFrequencyY: UILabel!
    @IBOutlet weak var fftStatsFrequencyZ: UILabel!
    
    @IBOutlet weak var fftStatsTimeDataInfoLabel: UILabel!
    @IBOutlet weak var fftStatsTimeX: UILabel!
    @IBOutlet weak var fftStatsTimeY: UILabel!
    @IBOutlet weak var fftStatsTimeZ: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var borderView: UIView?
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        fftStatsTtile.text = "FFT Details"
        TextLayout.title.apply(to: fftStatsTtile)
        
        fftFrequencyDataInfoLabel.text = "Frequency Data Info"
        fftStatsTimeDataInfoLabel.text = "Time Data Info"
        TextLayout.title2.apply(to: fftFrequencyDataInfoLabel)
        TextLayout.title2.apply(to: fftStatsTimeDataInfoLabel)
        
        TextLayout.info.apply(to: fftStatsFrequencyX)
        TextLayout.info.apply(to: fftStatsFrequencyY)
        TextLayout.info.apply(to: fftStatsFrequencyZ)
        
        TextLayout.info.apply(to: fftStatsTimeX)
        TextLayout.info.apply(to: fftStatsTimeY)
        TextLayout.info.apply(to: fftStatsTimeZ)
        

        Buttonlayout.rounded.apply(to: actionButton)

        borderView = containerView.apply(layout: ShapeLayout(color: ColorLayout.stGray5.light,
                                                             borderColor: .systemGray,
                                                             width: 1.0,
                                                             side: .all,
                                                             cornerRadius: 8.0,
                                                             overlay: false))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let borderView = borderView else {
            return
        }

        borderView.applyShadow(with: .systemGray)
    }
}
