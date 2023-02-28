//
//  PropertyRow.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 08/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class PropertyRow: UIView {
    
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        propertyLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        propertyLabel.textColor = currentTheme.color.textDark
        
        valueLabel.font = currentTheme.font.regular.withSize(14.0)
        valueLabel.textColor = currentTheme.color.textDark
    }

    deinit {
        guard let gestures = valueLabel.gestureRecognizers else { return }

        for gesture in gestures {
            valueLabel.removeGestureRecognizer(gesture)
        }
    }
    
    func configure(property: String, value: String) {
        propertyLabel.text = "\(property): "
        valueLabel.text = value
    }

    func configure(property: String, link: String) {
        propertyLabel.text = "\(property): "

        let attributedString = NSMutableAttributedString(string: link)
        attributedString.addAttribute(.link, value: link, range: NSRange(location: 0, length: attributedString.length))

        valueLabel.attributedText = attributedString
        valueLabel.isUserInteractionEnabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(labelPressed(_:)))
        gesture.numberOfTapsRequired = 1
        valueLabel.addGestureRecognizer(gesture)
    }

    @objc
    func labelPressed(_ sender: Any) {
        guard let text = valueLabel.text, let url = URL(string: text) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
