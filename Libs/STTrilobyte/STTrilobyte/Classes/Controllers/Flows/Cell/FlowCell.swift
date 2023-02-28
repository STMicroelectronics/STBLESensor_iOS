//
//  FlowCell.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 10/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FlowCellDelegate: class {
    func cell(_ cell: FlowCell, didPressUploadFlow flow: Flow)
    func cell(_ cell: FlowCell, didPressDeleteFlow flow: Flow)
}

class FlowCell: BaseTableViewCell<Flow> {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: FlowCellDelegate?
    
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
        publishButton.tintColor = currentTheme.color.secondary
        deleteButton.tintColor = currentTheme.color.secondary
        
    }
    
    // MARK: IBActions
    
    @IBAction func publishButtonPressed(_ sender: Any) {
        guard let delegate = delegate, let flow = model else { return }
        delegate.cell(self, didPressUploadFlow: flow)
    }
    
    @IBAction func removeButtonPressed(_ sender: Any) {
        guard let delegate = delegate, let flow = model else { return }
        delegate.cell(self, didPressDeleteFlow: flow)
    }
    
    // MARK: Public
    
    override func configure(with model: Flow, option: Option = .none) {
        self.model = model
        titleLabel.text = model.descr
        leftImage.image = UIImage.named(model.icon)
        publishButton.isHidden = model.hasOutputAsInput
        deleteButton.isHidden = !(option == .editable)
    }
    
}
