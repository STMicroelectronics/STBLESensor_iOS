//
//  CategoriesCell.swift
//  trilobyte-lib-ios
//
//  Created by Klaus Lanzarini on 17/12/20.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class CategoriesCell: BaseTableViewCell<Flow> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
        
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
        
        leftImage.tintColor = currentTheme.color.text
    }
    
    // MARK: Public
    override func configure(with model: Flow, option: Option = .none) {
        self.model = model
        titleLabel.text = model.category?.uppercased() ?? "---"
        leftImage.image = UIImage.named(model.icon)
        arrowImage.tintColor = currentTheme.color.secondary
    }
}
