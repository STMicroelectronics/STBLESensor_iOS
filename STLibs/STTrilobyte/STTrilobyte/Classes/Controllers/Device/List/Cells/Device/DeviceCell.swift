//
//  DeviceCell.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 17/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class DeviceCell: BaseTableViewCell<String> {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.text = nil
        
        publishButton.titleLabel?.font = currentTheme.font.regular.withSize(16.0)
        publishButton.setTitle("device_upload".localized(), for: .normal)
    
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
    
    override func configure(with model: String, option: Option = .none) {
        titleLabel.text = model
    }
}
