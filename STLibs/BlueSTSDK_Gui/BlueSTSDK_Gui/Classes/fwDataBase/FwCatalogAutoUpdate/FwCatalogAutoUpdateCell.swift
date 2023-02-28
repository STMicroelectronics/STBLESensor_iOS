//
//  FwCatalogAutoUpdateCell.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

class FwCatalogAutoUpdateCell: UITableViewCell {
    @IBOutlet weak var firmwareCurrentName: UILabel!
    @IBOutlet weak var firmwareUpdateName: UILabel!
    @IBOutlet weak var changeLog: UILabel!
    @IBOutlet weak var dontAskAgainCheckBox: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var installNow: UIButton!
}
