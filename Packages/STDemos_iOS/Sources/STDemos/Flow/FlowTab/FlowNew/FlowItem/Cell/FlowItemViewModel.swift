//
//  FlowItemViewModel.swift
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

class FlowItemViewModel: BaseCellViewModel<FlowItem, FlowItemCell> {

    let onFlowItemSettingsClicked: ((_ param: FlowItem) -> Void)
    let onFlowItemDeleteClicked: ((_ param: FlowItem) -> Void)
    
    var isInOverviewMode: Bool = false

    init(param: FlowItem, isInOverviewMode: Bool = false, onFlowItemSettingsClicked: @escaping ((_ param: FlowItem) -> Void), onFlowItemDeleteClicked: @escaping ((_ param: FlowItem) -> Void)) {
        self.onFlowItemSettingsClicked = onFlowItemSettingsClicked
        self.onFlowItemDeleteClicked = onFlowItemDeleteClicked
        self.isInOverviewMode = isInOverviewMode
        
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func configure(view: FlowItemCell) {
        TextLayout.info.apply(to: view.flowItemCellLabel)

        guard let param = param else { return }

        view.flowItemCellLabel.text = param.descr

        view.flowItemCellImage.contentMode = .scaleAspectFit
        setImage(view: view, param: param)
        
        if !isInOverviewMode {
            Buttonlayout.imageCleared(image: ImageLayout.Common.gear?.withTintColor(ColorLayout.primary.light)).apply(to: view.flowItemCellSettingsButton)
            Buttonlayout.imageCleared(image: ImageLayout.Common.delete?.maskWithColor(color: ColorLayout.redDark.auto)).apply(to: view.flowItemCellDeleteButton)
        }
        
        view.flowItemCellSettingsButton.on(.touchUpInside) { [weak self] _ in
            self?.onFlowItemSettingsClicked(param)
        }
        
        view.flowItemCellDeleteButton.on(.touchUpInside) { [weak self] _ in
            self?.onFlowItemDeleteClicked(param)
        }
        
        view.flowItemCellSettingsButton.isUserInteractionEnabled = true
        view.flowItemCellSettingsButton.isHidden = !param.hasSettings()
    }
    
    private func setImage(view: FlowItemCell, param: FlowItem) {
        if let param = param as? Sensor {
            view.flowItemCellImage.image = param.sensorIconToImage(icon: param.icon)
        } else if param is Function {
            view.flowItemCellImage.image = ImageLayout.image(with: "flow_function", in: .module)?.maskWithColor(color: ColorLayout.primary.light)
            view.flowItemCellDeleteButton.isHidden = false
        } else {
            view.flowItemCellImage.image = ImageLayout.image(with: param.itemIcon, in: .module)?.maskWithColor(color: ColorLayout.primary.light)
        }
    }
}
