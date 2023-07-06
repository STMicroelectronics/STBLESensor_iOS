//
//  SensorView.swift
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

class SensorView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var uomSwitch: UISwitch!
    @IBOutlet weak var offsetTextField: UITextField!
    @IBOutlet weak var offsetLabel: UILabel!

    var containerView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        stackView.backgroundColor = .clear

        offsetTextField.keyboardType = .numbersAndPunctuation

        TextLayout.title.apply(to: valueLabel)
        TextLayout.subtitle.apply(to: uomLabel)
        TextLayout.subtitle.apply(to: offsetLabel)

        valueLabel.text = ""
        uomLabel.text = "°C/°F"

        containerView = stackView.apply(layout: ShapeLayout(color: ColorLayout.systemWhite.autoInverted,
                                                            borderColor: .clear,
                                                            width: 1.0,
                                                            side: .all,
                                                            cornerRadius: 8.0,
                                                            overlay: false))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let containerView = containerView else {
            return
        }

        containerView.applyShadow()
    }
}
