//
//  PnpLComponentViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI

class PnpLComponentViewModel: BaseCellViewModel<PnpLComponentContent, PnpLComponentTableViewCell> {

    override func configure(view: PnpLComponentTableViewCell) {
        view.componentLabel.text = param?.displayName?.en
    }
}

class PnpLComponentTableViewCell: UITableViewCell {
    @IBOutlet weak var componentLabel: UILabel!
}
