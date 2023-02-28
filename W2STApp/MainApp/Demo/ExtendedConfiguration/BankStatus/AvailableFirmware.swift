//
//  FlashMemoryBankCell.swift
//  W2STApp
//
//  Created by Giuseppe Paris on 03/05/22.
//  Copyright © 2022 STMicroelectronics. All rights reserved.
//

import UIKit

class AvailableFirmware: UITableViewCell {
    @IBOutlet weak var fwName: UILabel!
    @IBOutlet weak var fwVersion: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        accessoryType = selected ? .checkmark : .none
    }

}
