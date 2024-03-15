//
//  CheckBoxRow.swift
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

protocol CheckBoxRowDelegate: AnyObject {
    func checkBoxRow(didPressOption option: Checkable, value: Bool)
}

class CheckBoxRow: UIView {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    var item: Checkable?
    var singleSelection: Bool = false
    
    weak var delegate: CheckBoxRowDelegate?

    private var completionHandler: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        TextLayout.text.apply(to: textLabel)
//        textLabel.font = currentTheme.font.regular
//        textLabel.textColor = currentTheme.color.textDark
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        if singleSelection {
            actionButton.isSelected = true
        } else {
            actionButton.isSelected = !actionButton.isSelected
        }
        
        guard let item = item else { return }

        delegate?.checkBoxRow(didPressOption: item, value: actionButton.isSelected)

        if let completionHandler = completionHandler {
            completionHandler(actionButton.isSelected)
        }
    }
    
    func addCompletion(completionHandler: @escaping (Bool) -> Void) {
        self.completionHandler = completionHandler
    }
}

extension CheckBoxRow {

    func configureWith(_ item: Checkable, checked: Bool, singleSelection: Bool) {
        if singleSelection {
            configureRadioWith(item, checked: checked)
        } else {
            configureCheckWith(item, checked: checked)
        }
    }

    func configureCheckWith(_ item: Checkable, checked: Bool) {
        self.item = item
        textLabel.text = item.descr
        actionButton.isSelected = checked
        singleSelection = false

        actionButton.setImage(ImageLayout.Common.squareUnchecked?.withTintColor(ColorLayout.primary.auto), for: .normal)
        actionButton.setImage(ImageLayout.Common.squareChecked?.withTintColor(ColorLayout.primary.auto), for: .selected)
    }
    
    func configureRadioWith(_ item: Checkable, checked: Bool) {
        self.item = item
        textLabel.text = item.descr
        actionButton.isSelected = checked
        singleSelection = true
        
        actionButton.setImage(ImageLayout.Common.radioUnchecked?.withTintColor(ColorLayout.primary.auto), for: .normal)
        actionButton.setImage(ImageLayout.Common.radioChecked?.withTintColor(ColorLayout.primary.auto), for: .selected)
    }
}

