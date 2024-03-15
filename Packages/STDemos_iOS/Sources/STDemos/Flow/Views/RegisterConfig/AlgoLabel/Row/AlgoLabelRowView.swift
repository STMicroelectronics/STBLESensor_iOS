//
//  AlgoLabelRowView.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

class AlgoLabelRowView: UIView {
    
    private let mCloseKeyboardOnReturnDelegate = CloseKeyboardOnReturn()
    
    @IBOutlet weak var rowStackPanel: UIStackView!
    @IBOutlet weak var outputTextField: UITextField!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func onDeleteButtonPressed(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.setTitle("", for: .normal)
        deleteButton.setImage(ImageLayout.Common.delete?.scalePreservingAspectRatio(targetSize: ImageSize.small).withTintColor(ColorLayout.red.auto), for: .normal)
        outputTextField.delegate = mCloseKeyboardOnReturnDelegate
        labelTextField.delegate = mCloseKeyboardOnReturnDelegate
    }
    
    func setValue(value: String) {
        outputTextField.text = value
    }
    
    func setLabel(label: String) {
        labelTextField.text = label
    }
}
