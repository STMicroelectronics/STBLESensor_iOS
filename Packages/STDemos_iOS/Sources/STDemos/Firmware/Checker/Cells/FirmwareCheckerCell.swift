//
//  FirmwareCheckerCell.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public class FirmwareCheckerCell: BaseTableViewCell {

    @IBOutlet weak var currentFirmwareLabel: UILabel!
    @IBOutlet weak var updateFirmwareLabel: UILabel!
    @IBOutlet weak var changeLogLabel: UILabel!
    @IBOutlet weak var dontAskAgainButton: UIButton!

    @IBOutlet weak var currentFirmwareDescLabel: UILabel!
    @IBOutlet weak var updateFirmwareDescLabel: UILabel!
    @IBOutlet weak var changeLogDescLabel: UILabel!
    @IBOutlet weak var dontAskAgainDescLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var installButton: UIButton!

    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
