//
//  UserProfilingView.swift
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

public final class UserProfilingView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var optionsStackView: UIStackView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in optionsStackView.arrangedSubviews {
            view.removeFromSuperview()
            optionsStackView.removeArrangedSubview(view)
        }
        
        TextLayout.title2
            .alignment(.center)
            .apply(to: title)
        
        TextLayout.text
            .alignment(.center)
            .apply(to: titleLabel)
        TextLayout.text.apply(to: contentLabel)
        
        Buttonlayout.standard.apply(to: nextButton)
    }
}
