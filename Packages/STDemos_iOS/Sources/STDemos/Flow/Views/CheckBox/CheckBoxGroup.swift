//
//  CheckBoxGroup.swift
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

class CheckBoxGroup: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    var singleSelection: Bool = false
    var items: [Checkable]?
    var selectedItems: [Checkable] = [Checkable]()

    private var completionHandler: (([Checkable]) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String,
                   items: [Checkable],
                   selectedItems: [Checkable],
                   singleSelection: Bool = false,
                   completionHandler: @escaping ([Checkable]) -> Void) {
        self.items = items
        self.selectedItems = selectedItems
        self.singleSelection = singleSelection

        guard !items.isEmpty else { return }

        let titleLabel = UILabel()
        titleLabel.font = FontLayout.bold
        titleLabel.textColor = ColorLayout.primary.auto
        titleLabel.backgroundColor = .clear
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)

        for item in items {
            let optionView: CheckBoxRow = CheckBoxRow.createFromNib()

            optionView.configureWith(item,
                                     checked: selectedItems.contains {
                                        if let selectedItem = $0 as? Sensor,
                                        let currentItem = item as? Sensor{
                                         return selectedItem == currentItem
                                     }else{
                                         return $0.identifier == item.identifier
                                     } },
                                     singleSelection: singleSelection)

            optionView.delegate = self
            stackView.addArrangedSubview(optionView)
        }

        self.completionHandler = completionHandler

        stackView.addArrangedSubview(UIView())
    }
}

extension CheckBoxGroup: CheckBoxRowDelegate {
    func checkBoxRow(didPressOption option: Checkable, value: Bool) {

        guard let items = items else { return }

        if singleSelection {
            selectedItems.removeAll()
            if value {
                selectedItems.append(option)
            }
        } else {
            if value {
                selectedItems.append(option)
            } else {
                selectedItems.removeAll {
                    if let selectedItem = $0 as? Sensor,
                       let currentItem = option as? Sensor{
                        return selectedItem == currentItem
                    }else{
                        return $0.identifier == option.identifier
                    }
                }
            }
        }

        for (index, item) in items.enumerated() {
            if let optionView = stackView.arrangedSubviews[index + 1] as? CheckBoxRow {
                optionView.configureWith(item,
                                         checked: selectedItems.contains {
                                            if let selectedItem = $0 as? Sensor,
                                               let currentItem = item as? Sensor{
                                                return selectedItem == currentItem
                                            }else{
                                                return $0.identifier == item.identifier
                                            }
                                            
                    },
                                         singleSelection: singleSelection)
            }
        }

        if let completionHandler = completionHandler {
            completionHandler(selectedItems)
        }
    }
}

