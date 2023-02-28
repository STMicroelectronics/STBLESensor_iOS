//
//  FooterView.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FooterDelegate: class {
    
    func leftButtonPressed()
    
    func rightButtonPressed()
}

class FooterView: UIView {
    
    weak var delegate: FooterDelegate?

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = currentTheme.color.background
        leftButton.setTitleColor(currentTheme.color.textDark, for: .normal)
        leftButton.tintColor = currentTheme.color.textDark
        rightButton.setTitleColor(currentTheme.color.secondary, for: .normal)
        rightButton.setTitleColor(currentTheme.color.text, for: .disabled)
        rightButton.tintColor = currentTheme.color.secondary
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        applyShadow(with: currentTheme.color.text, alpha: 0.5, path: UIBezierPath(rect: rect))
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        guard let delegate = delegate else { return }
        
        delegate.leftButtonPressed()
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        guard let delegate = delegate else { return }
        
        delegate.rightButtonPressed()
    }
    
}
