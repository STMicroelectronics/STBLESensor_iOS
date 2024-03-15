//
//  FlowOutputViewModel.swift
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
import STBlueSDK

class FlowOutputViewModel: BaseCellViewModel<FlowItem, FlowOutputCell> {

    static var selectedItems = [Checkable]()
    var isSelected = false
    var completionHandler: (([Checkable]) -> Void)?
    
    init(param: FlowItem, isSelected: Bool, completionHandler: @escaping ([Checkable]) -> Void) {
        super.init(param: param)
        self.isSelected = isSelected
        self.completionHandler = completionHandler
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func configure(view: FlowOutputCell) {
        TextLayout.info.apply(to: view.outputLabel)

        view.outputSelector.addTarget(self, action: #selector(selectorChanged), for: .valueChanged)
        
        guard let param = param else { return }
        view.outputLabel.text = param.descr
        view.outputSelector.isOn = isSelected
        
        if isSelected {
            if let param = param as? Output {
                FlowOutputViewModel.selectedItems.append(param)
            }
        }
    }
    
    @objc func selectorChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            if let param = param as? Output {
                FlowOutputViewModel.selectedItems.append(param)
            }
        } else {
            FlowOutputViewModel.selectedItems.removeAll {
                if let selectedItem = $0 as? Output,
                   let currentItem = param as? Output{
                    return selectedItem == currentItem
                }else{
                    if let param = param as? Output {
                        return $0.identifier == param.identifier
                    }
                }
                return false
            }
        }
        if let completionHandler = completionHandler {
            completionHandler(FlowOutputViewModel.selectedItems)
        }
        
    }
}

