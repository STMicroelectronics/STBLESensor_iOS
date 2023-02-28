//
//  FlowSelectCell.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 24/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class FlowSelectCell: BaseTableViewCell<Flow> {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    // MARK: View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        
        checkButton.setImage(UIImage.named("img_unchecked"), for: .normal)
        checkButton.setImage(UIImage.named("img_check"), for: .selected)
        checkButton.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        checkButton.isSelected = false
    }
    
    // MARK: IBActions
    
    @IBAction func checkButtonPressed(_ sender: Any) {
        
    }
 
    // MARK: Public methods
    
    override func configure(with model: Flow, option: Option = .none) {
        
        titleLabel.text = model.name
        checkButton.isSelected = option == .selected
        
    }
    
}
