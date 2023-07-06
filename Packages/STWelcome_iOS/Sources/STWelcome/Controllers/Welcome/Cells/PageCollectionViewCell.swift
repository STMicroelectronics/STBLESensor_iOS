//
//  PageCollectionViewCell.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

class PageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        TextLayout.title2
            .alignment(.center)
            .apply(to: titleLabel)
        
        TextLayout.info
            .alignment(.center)
            .apply(to: contentLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
