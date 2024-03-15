//
//  FlowMoreItemViewModel.swift
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

public class FlowMoreItemViewModel: BaseCellViewModel<FlowMoreItem, FlowMoreItemCell> {

    let urlHandler: (() -> Void)?

    public init(param: FlowMoreItem, urlHandler: (() -> Void)?) {
        self.urlHandler = urlHandler

        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: FlowMoreItemCell) {
        TextLayout.info.size(16.0).apply(to: view.itemLabel)

        guard let param = param else { return }

        view.itemLabel.text = param.name

        view.itemIcon.contentMode = .scaleAspectFill
        view.itemIcon.image = ImageLayout.image(with: param.imageName, in: .module)?.maskWithColor(color: ColorLayout.primary.light)

        view.itemDisclosureIcon.contentMode = .scaleAspectFill
        view.itemDisclosureIcon.image = ImageLayout.image(with: "flow_arrow_forward", in: .module)?.maskWithColor(color: ColorLayout.primary.light)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(flowMoreItemTapped(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(viewTap)
    }
}

extension FlowMoreItemViewModel {
    @objc
    func flowMoreItemTapped(_ sender: UITapGestureRecognizer) {
        if let param = param {
            if let url = URL(string: param.link) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
