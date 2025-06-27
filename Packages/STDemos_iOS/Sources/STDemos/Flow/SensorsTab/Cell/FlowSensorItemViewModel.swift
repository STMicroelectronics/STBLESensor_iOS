//
//  FlowSensorItemViewModel.swift
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

public class FlowSensorItemViewModel: BaseCellViewModel<Sensor, FlowSensorItemCell> {

    let onFlowSensorClicked: ((_ param: Sensor) -> Void)
    var isMounted: Bool

    public init(param: Sensor, isMounted: Bool, onFlowSensorClicked: @escaping ((_ param: Sensor) -> Void)) {
        self.onFlowSensorClicked = onFlowSensorClicked
        self.isMounted = isMounted
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: FlowSensorItemCell) {
        TextLayout.title2.size(16.0).apply(to: view.flowSensorName)
        TextLayout.info.apply(to: view.flowSensorDetailedName)

        guard let param = param else { return }

        view.flowSensorName.text = param.descr
        view.flowSensorDetailedName.text = param.model

        view.flowSensorIcon.contentMode = .scaleAspectFit
        view.flowSensorIcon.image = param.sensorIconToImage(icon: param.icon)

        view.flowSensorDisclosureIcon.contentMode = .scaleAspectFit
        view.flowSensorDisclosureIcon.image = ImageLayout.image(with: "flow_arrow_forward", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)

        if !isMounted {
            view.flowNotMountedLabel.isHidden = false
        }
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(flowSensorItemTapped(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(viewTap)
    }
}

extension FlowSensorItemViewModel {
    @objc
    func flowSensorItemTapped(_ sender: UITapGestureRecognizer) {
        if let param = param {
            onFlowSensorClicked(param)
        }
    }
}
