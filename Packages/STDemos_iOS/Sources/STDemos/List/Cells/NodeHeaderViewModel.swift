//
//  NodeHeaderViewModel.swift
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
import STCore

public class NodeHeaderViewModel: BaseCellViewModel<Node, NodeHeaderCell> {

    public override func configure(view: NodeHeaderCell) {

        TextLayout.title.size(20.0).apply(to: view.nodeTextLabel)
        //TextLayout.info.apply(to: view.nodeDetailTextLabel)
        TextLayout.info.apply(to: view.nodeExtraTextLabel)

        guard let param = param else { return }

        view.nodeTextLabel.text = param.name
        //view.nodeDetailTextLabel.text = param.name

        view.nodeImageView.contentMode = .scaleAspectFit
        view.nodeImageView.image = param.image
//        view.nodeImageView.backgroundColor = ColorLayout.secondary.light

        guard param.protocolVersion == 0x02 else { return }

        guard let catalogService: CatalogService = Resolver.shared.resolve(),
              let catalog = catalogService.catalog else { return }

        if let firmware = catalog.v2Firmware(with: param.deviceId.longHex,
                                          firmwareId: UInt32(param.bleFirmwareVersion).longHex) {
            if !firmware.fullName.isEmpty {
                view.divisor.isHidden = false
                view.nodeExtraTextLabel.text = firmware.fullName
            }

            if firmware.bleVersionId == 255 {
                let demos = Demo.demos(with: param.characteristics.allFeatures())
                let pnpLSet = Set([Demo.pnpLike])
                let demosSet = Set(demos)
                let hasPnPL = pnpLSet.isSubset(of: demosSet)
                
                if hasPnPL {
                    if catalogService.customDtmi == nil {
                        view.customDtmiLabel.text = "Custom DTMI not present"
                        TextLayout.infoBold.color(ColorLayout.accent.light).apply(to: view.customDtmiLabel)
                    } else {
                        view.customDtmiLabel.text = "Custom DTMI"
                        TextLayout.infoBold.color(ColorLayout.green.light).apply(to: view.customDtmiLabel)
                    }
                    view.customDtmiLabel.isHidden = false
                }
            }
        }
    }
}

extension Node {
    var image: UIImage? {
        guard let imageName = type.imageName else { return nil }
        return UIImage(named: imageName, in: STUI.bundle, compatibleWith: nil)
    }
}
