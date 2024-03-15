//
//  AlgoLabelView.swift
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

class AlgoLabelView: UIView {
    
    private let mCloseKeyboardOnReturnDelegate = CloseKeyboardOnReturn()
    
    @IBOutlet weak var algoNumberLabel: UILabel!
    @IBOutlet weak var algoNameTextField: UITextField!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var labelStackPanel: UIStackView!
    @IBOutlet weak var addLabelButton: UIButton!
    @IBOutlet weak var labelView: UIStackView!
    
    @IBOutlet weak var outputTitle: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    var labelRows: [AlgoLabelRowView] { labelStackPanel.arrangedSubviews as! [AlgoLabelRowView] }
    
    private let arrowDown = ImageLayout.Common.arrowDown?.scalePreservingAspectRatio(targetSize: ImageSize.small).withTintColor(ColorLayout.primary.auto)
    private let arrowUp = ImageLayout.Common.arrowUp?.scalePreservingAspectRatio(targetSize: ImageSize.small).withTintColor(ColorLayout.primary.auto)
    private let addRow = ImageLayout.Common.addRow?.scalePreservingAspectRatio(targetSize: ImageSize.medium).withTintColor(ColorLayout.primary.auto)
    
    var index: ValueLabelMapper.RegisterIndex!
    private var valueMapper: ValueLabelMapper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        TextLayout.bold.apply(to: outputTitle)
        TextLayout.bold.apply(to: labelTitle)
        
        expandButton.setTitle("", for: .normal)
        expandButton.setImage(arrowDown, for: .normal)
        addLabelButton.setTitle("", for: .normal)
        addLabelButton.setImage(addRow, for: .normal)
        
        algoNameTextField.delegate = mCloseKeyboardOnReturnDelegate
    }
    
    @IBAction func expandButtonPressed(_ sender: Any) {
        if (labelView.isHidden) {
            labelView.isHidden = false
            expandButton.setImage(arrowUp, for: .normal)
        } else {
            labelView.isHidden = true
            expandButton.setImage(arrowDown, for: .normal)
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
