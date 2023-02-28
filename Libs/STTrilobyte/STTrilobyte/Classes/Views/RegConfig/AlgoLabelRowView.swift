//
//  RegConfigView.swift
//  trilobyte-lib-ios
//
//  Created by STMicroelectronics MEMS on 12/12/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import Foundation

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
