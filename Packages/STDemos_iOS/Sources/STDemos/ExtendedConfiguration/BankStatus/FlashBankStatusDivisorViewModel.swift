//
//  FlashBankStatusDivisorViewModel.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

public class DivisorCell: BaseTableViewCell {
    let containerView = UIView()
    
    let divisor = UIView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0)

        containerView.addSubview(divisor)
        divisor.addFitToSuperviewConstraints(top: 4.0, leading: 10.0, bottom: 4.0, trailing: 10.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DivisorViewModel: BaseCellViewModel<Void, DivisorCell> {

    required init() {
        super.init()
    }

    override func configure(view: DivisorCell) {
        view.divisor.backgroundColor = ColorLayout.stGray5.light
        view.divisor.setDimensionContraints(height: 1)
    }
}
