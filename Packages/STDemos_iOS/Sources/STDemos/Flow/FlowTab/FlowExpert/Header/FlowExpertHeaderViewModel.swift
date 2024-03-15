//
//  FlowExpertHeaderViewModel.swift
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

public class FlowExpertHeaderViewModel: BaseCellViewModel<Node, FlowExpertHeaderCell> {

    let newAppHandler: (() -> Void)?
    let ifHandler: (() -> Void)?
    
    public init(param: Node, newAppHandler: (() -> Void)?, ifHandler: (() -> Void)?) {
        self.newAppHandler = newAppHandler
        self.ifHandler = ifHandler
        
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: FlowExpertHeaderCell) {

        Buttonlayout.standardWithImage(image: ImageLayout.Common.add).apply(to: view.newAppButton, text: "NEW APP")
        Buttonlayout.standard.apply(to: view.ifButton, text: "IF")
        
        view.newAppButton.setDimensionContraints(width: 130.0)

        view.newAppButton.on(.touchUpInside) { [weak self] _ in
            guard let newAppHandler = self?.newAppHandler else { return }
            newAppHandler()
        }
        
        view.ifButton.on(.touchUpInside) { [weak self] _ in
            guard let ifHandler = self?.ifHandler else { return }
            ifHandler()
        }
    }
}
