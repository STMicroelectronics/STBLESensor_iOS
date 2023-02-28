//
//  FlowRowView.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 15/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class FlowRowView: UIView {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with flowItem: FlowItem, last: Bool = false) {
        iconView.image = UIImage.named(flowItem.itemIcon)
        iconView.tintColor = currentTheme.color.text
        
        titleLabel.text = flowItem.descr
        titleLabel.textColor = currentTheme.color.text
        titleLabel.font = currentTheme.font.regular.withSize(14.0)
        
        if !last {
            applyStyle(.bottomBorder(insets: .zero, cornerRadius: 0.0, height: 1.0),
                       fillColor: currentTheme.color.text,
                       strokeColor: nil,
                       overlay: true)
        }
    }
}
