//
//  FlowRow.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 15/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

enum ItemPosition {
    case first
    case middle
    case last
}

class FlowContainerView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(_ title: String, with items: [FlowItem], in position: ItemPosition) {
        titleLabel.text = title.uppercased()
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        stackView.applyStyle(.border(insets: .zero, cornerRadius: 0.0, height: 1.0),
                             fillColor: nil,
                             strokeColor: currentTheme.color.text,
                             overlay: true)
        
        topLine.backgroundColor = currentTheme.color.text
        bottomLine.backgroundColor = currentTheme.color.text
        
        for (index, item) in items.enumerated() {
            let view: FlowRowView = FlowRowView.createFromNib()
            view.configure(with: item, last: index == items.count - 1)
            stackView.addArrangedSubview(view)
        }
        
        switch position {
        case .first:
            topLine.isHidden = true
            bottomLine.isHidden = false
        case .middle:
            topLine.isHidden = false
            bottomLine.isHidden = false
        case .last:
            topLine.isHidden = false
            bottomLine.isHidden = true
        }
    }
}
