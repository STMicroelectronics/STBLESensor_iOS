//
//  NodeCell.swift
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

class NodeCell: BaseTableViewCell {

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var nodeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var rssiImageView: UIImageView!
    @IBOutlet weak var firmwareLabel: UILabel!

    @IBOutlet weak var customModelLabel: UILabel!
    @IBOutlet weak var maturityLabel: UILabel!
    
    @IBOutlet weak var nodeRunningSecondLabel: UILabel!
    @IBOutlet weak var nodeRunningThirdInfoLabel: UILabel!

    @IBOutlet weak var isSleepingImageView: UIImageView!
    @IBOutlet weak var hasExtensionImageView: UIImageView!

    @IBOutlet var nodeRunningImageViews: [UIImageView]!

    @IBOutlet weak var actionButton: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.cornerRadius = 8.0
        containerView.backgroundColor = .white
        containerView.applyShadow()
    }
}
