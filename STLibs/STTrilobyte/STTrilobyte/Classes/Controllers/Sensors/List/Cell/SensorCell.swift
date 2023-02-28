//
//  SensorCell.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 08/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class SensorCell: BaseTableViewCell<Sensor> {
    
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    
    // MARK: View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.applyStyle(.border(insets: UIEdgeInsets(top: 6.0, left: 24.0, bottom: -6.0, right: -24.0), cornerRadius: 5.0, height: 1.0),
                               fillColor: currentTheme.color.cardPrimary,
                               strokeColor: currentTheme.color.cardSecondary,
                               overlay: false)
        contentView.applyShadow()
        
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        
        subtitleLabel.font = currentTheme.font.regular.withSize(14.0)
        subtitleLabel.textColor = currentTheme.color.text
        
        detailImage.tintColor = currentTheme.color.secondary
    }
    
    // MARK: Public
    
    override func configure(with model: Sensor, option: Option = .none) {
        titleLabel.text = model.descr
        subtitleLabel.text = model.model
        sensorImage.image = UIImage.named(model.icon)
        sensorImage.tintColor = .red
    }

}
