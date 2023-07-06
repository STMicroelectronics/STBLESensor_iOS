//
//  FirmwareViewModel.swift
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

public class FirmwareViewModel: BaseCellViewModel<Firmware, FirmwareCell> {

    public override func configure(view: FirmwareCell) {

        TextLayout.title2.apply(to: view.titleLabel)
        TextLayout.text.apply(to: view.versionLabel)
        TextLayout.info.apply(to: view.changelogLabel)

        guard let param = param else { return }

        view.titleLabel.text = param.name
        view.versionLabel.text = param.version
        view.changelogLabel.text = param.description ?? "--"

    }
}
