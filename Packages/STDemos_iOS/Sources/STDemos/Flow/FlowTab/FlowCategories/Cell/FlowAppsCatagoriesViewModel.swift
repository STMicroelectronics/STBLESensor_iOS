//
//  FlowAppsCatagoriesViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

public class FlowAppsCatagoriesViewModel: BaseCellViewModel<FlowCategory, FlowAppsCategoriesCell> {

    let onFlowAppCategoryClicked: ((_ param: FlowCategory) -> Void)

    public init(param: FlowCategory, onFlowAppCategoryClicked: @escaping ((_ param: FlowCategory) -> Void)) {
        self.onFlowAppCategoryClicked = onFlowAppCategoryClicked

        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: FlowAppsCategoriesCell) {
        TextLayout.title2.size(16.0).apply(to: view.flowAppCategoryName)

        guard let param = param else { return }

        view.flowAppCategoryName.text = param.name

        view.flowAppCategoryIcon.contentMode = .scaleAspectFill
        view.flowAppCategoryIcon.image = ImageLayout.image(with: "flow_unfold_more", in: .module)?.maskWithColor(color: ColorLayout.primary.light)

        view.flowAppCategoryDisclosureIcon.contentMode = .scaleAspectFill
        view.flowAppCategoryDisclosureIcon.image = ImageLayout.image(with: "flow_arrow_forward", in: .module)?.maskWithColor(color: ColorLayout.primary.light)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(flowAppCategoryItemTapped(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(viewTap)
    }
}

extension FlowAppsCatagoriesViewModel {
    @objc
    func flowAppCategoryItemTapped(_ sender: UITapGestureRecognizer) {
        if let param = param {
            onFlowAppCategoryClicked(param)
        }
    }
}
