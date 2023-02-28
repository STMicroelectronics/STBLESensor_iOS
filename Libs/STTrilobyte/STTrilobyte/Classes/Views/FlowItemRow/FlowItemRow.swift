//
//  FlowItemRow.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 28/03/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FlowItemRowDelegate: class {
    func didPressRowItem(item: FlowItemRow)
    func didPressSettings(item: FlowItemRow)
}

class FlowItemRow: UIView {
    
    @IBOutlet weak var itemButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    weak var delegate: FlowItemRowDelegate?

    var flowItem: FlowItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    func configure(with flowItem: FlowItem) {
        self.flowItem = flowItem

        itemButton.setTitle(flowItem.descr, for: .normal)
        itemButton.setImage(UIImage.named(flowItem.itemIcon), for: .normal)
        
        settingsButton.isHidden = !flowItem.hasSettings()
    }
    
    @IBAction func itemButtonPressed(_ sender: Any) {
        guard let delegate = delegate else { return }
        
        delegate.didPressRowItem(item: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        guard let delegate = delegate else { return }
        
        delegate.didPressSettings(item: self)
    }
}

private extension FlowItemRow {
    func configureView() {
        itemButton.titleLabel?.font = currentTheme.font.regular.withSize(16.0)
        itemButton.setTitleColor(currentTheme.color.textDark, for: .normal)
        itemButton.tintColor = currentTheme.color.textDark
        
        settingsButton.tintColor = currentTheme.color.textDark
        backgroundColor = currentTheme.color.cardPrimary
    }
}
