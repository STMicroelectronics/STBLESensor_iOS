//
//  CallbackAlertView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class CallbackAlertView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var borderView: UIView?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        TextLayout.text
            .alignment(.center)
            .color(ColorLayout.systemBlack.light)
            .apply(to: textLabel)
        
        Buttonlayout.rounded
            .apply(to: actionButton)
        
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
