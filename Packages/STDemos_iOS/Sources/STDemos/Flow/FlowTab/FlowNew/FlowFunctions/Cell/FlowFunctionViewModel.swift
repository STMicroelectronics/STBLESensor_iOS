//
//  FlowFunctionViewModel.swift
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

class FlowFunctionViewModel: BaseCellViewModel<FlowItem, FlowFunctionCell> {

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

    override func configure(view: FlowFunctionCell) {
        TextLayout.info.apply(to: view.functionLabel)

        view.functionSelector.addTarget(self, action: #selector(selectorChanged), for: .valueChanged)
        
        guard let param = param else { return }
        view.functionLabel.text = param.descr
        view.functionSelector.isOn = isSelected
    }
    
    @objc func selectorChanged(mySwitch: UISwitch) {
        if let param = param {
            if let param = param as? Function {
                if let completionHandler = completionHandler {
                    completionHandler(IsItemChecked(checkable: param, isChedked: mySwitch.isOn))
                }
            }
        }
    }
}
