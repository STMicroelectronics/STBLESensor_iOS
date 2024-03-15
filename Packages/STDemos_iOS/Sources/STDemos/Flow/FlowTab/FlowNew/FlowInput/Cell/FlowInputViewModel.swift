//
//  FlowInputViewModel.swift
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

class FlowInputViewModel: BaseCellViewModel<FlowItem, FlowInputCell> {

    var isSelected = false
    var completionHandler: ((IsItemChecked) -> Void)?
    
    init(param: FlowItem, isSelected: Bool, completionHandler: @escaping (IsItemChecked) -> Void) {
        super.init(param: param)
        self.isSelected = isSelected
        self.completionHandler = completionHandler
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func configure(view: FlowInputCell) {
        TextLayout.info.apply(to: view.inputLabel)
        
        guard let param = param else { return }
        view.inputLabel.text = param.descr
        view.inputSelector.isOn = isSelected
        
        view.inputSelector.on(.valueChanged) { [weak self] selector in
            if let param = param as? Checkable {
                if let completionHandler = self?.completionHandler {
                    completionHandler(IsItemChecked(checkable: param, isChedked: selector.isOn))
                }
            }
        }
    }
}

public struct IsItemChecked {
    let checkable: Checkable
    let isChedked: Bool
}
