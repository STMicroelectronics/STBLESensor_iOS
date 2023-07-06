//
//  ContainerCell.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class ContainerCell: BaseTableViewCell {
    let containerView = UIView()
    let stackView = UIStackView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.clipsToBounds = true

        clear()

        self.containerView.addSubview(stackView, margin: .zero)
        self.contentView.addSubview(containerView, margin: .zero)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.clipsToBounds = true

        clear()

        self.containerView.addSubview(stackView, margin: .zero)
        self.contentView.addSubview(containerView, margin: .zero)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
    }

    open override func update(_ margin: Margin) {
        stackView.change(margin)
        containerView.change(margin)
        contentView.change(margin)
    }

}
