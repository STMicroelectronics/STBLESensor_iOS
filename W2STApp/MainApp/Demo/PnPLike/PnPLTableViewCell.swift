//
//  PnPLTableViewCell.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

class PnPLTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var enabled: UISwitch!
    @IBOutlet weak var exapandButton: UIButton!
    
    @IBOutlet weak var detailedStackView: UIStackView!
}
