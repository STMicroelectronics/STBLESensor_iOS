//
//  CheckButtonView.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol CheckBoxRowDelegate: class {
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

        textLabel.font = currentTheme.font.regular
        textLabel.textColor = currentTheme.color.textDark
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

        actionButton.setImage(UIImage.named("img_unchecked")?.withRenderingMode(.alwaysTemplate), for: .normal)
        actionButton.setImage(UIImage.named("img_check")?.withRenderingMode(.alwaysTemplate), for: .selected)
    }
    
    func configureRadioWith(_ item: Checkable, checked: Bool) {
        self.item = item
        textLabel.text = item.descr
        actionButton.isSelected = checked
        singleSelection = true
        
        actionButton.setImage(UIImage.named("img_radio_unchecked")?.withRenderingMode(.alwaysTemplate), for: .normal)
        actionButton.setImage(UIImage.named("img_radio_check")?.withRenderingMode(.alwaysTemplate), for: .selected)
    }
}
