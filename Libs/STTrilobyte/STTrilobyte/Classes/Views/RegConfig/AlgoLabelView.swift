//
//  RegConfigView.swift
//  trilobyte-lib-ios
//
//  Created by STMicroelectronics MEMS on 12/12/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import Foundation

class AlgoLabelView: UIView {
    
    private let mCloseKeyboardOnReturnDelegate = CloseKeyboardOnReturn()
    
    @IBOutlet weak var algoNumberLabel: UILabel!
    @IBOutlet weak var algoNameTextField: UITextField!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var labelStackPanel: UIStackView!
    @IBOutlet weak var addLabelButton: UIButton!
    @IBOutlet weak var labelView: UIView!
    
    var labelRows: [AlgoLabelRowView] { labelStackPanel.arrangedSubviews as! [AlgoLabelRowView] }
    
    var index: ValueLabelMapper.RegisterIndex!
    private var valueMapper: ValueLabelMapper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        algoNameTextField.delegate = mCloseKeyboardOnReturnDelegate
    }
    
    @IBAction func expandButtonPressed(_ sender: Any) {
        if (labelView.isHidden) {
            labelView.isHidden = false
            expandButton.setImage(UIImage.named("img_expand_less"), for: .normal)
        } else {
            labelView.isHidden = true
            expandButton.setImage(UIImage.named("img_expand_more"), for: .normal)
        }
    }
    
    @IBAction func addLabelButtonPressed(_ sender: Any) {
        addLabelRow(value: 0, label: "label")
    }
    
    func setAlgoName(name: String) {
        algoNameTextField.text = name
    }
    
    func setAlgoNumber(name: String) {
        algoNumberLabel.text = name
    }
    
    func setExpandButtonHidden(state: Bool) {
        expandButton.isHidden = state
    }
    
    func addLabelRow(value: UInt8, label: String) {
        let algoLabelRowView: AlgoLabelRowView = AlgoLabelRowView.createFromNib()
        
        algoLabelRowView.setValue(value: String(value))
        algoLabelRowView.setLabel(label: label)
        
        valueMapper?.addLabel(register: index, value: value, label: label)
        
        labelStackPanel.addArrangedSubview(algoLabelRowView)
    }
    
    func initLabelStackPanel(index: ValueLabelMapper.RegisterIndex, valueMapper: ValueLabelMapper) {
        
        self.index = index
        self.valueMapper = valueMapper
        let labelValues = valueMapper.getLabelValues(index: index)
        labelValues?
            .sorted { $0.key < $1.key }
            .forEach { value, label in
            addLabelRow(value: value, label: label)
        }
        
        labelView.isHidden = true
    }
}
