//
//  GroupTableViewCell.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class GroupTableViewCell: BaseTableViewCell {
    public let containerView = UIView()
    public let stackView = UIStackView()

    var isCard: Bool = true

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    open override func configureView() {
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.clipsToBounds = true

        clear()

        self.containerView.addSubview(stackView, margin: .zero)
        self.contentView.addSubview(containerView, margin: .zero)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if isCard {
            self.containerView.layer.cornerRadius = 8.0
            self.containerView.backgroundColor = .white
            containerView.applyShadow()
        }
    }

    open override func update(_ margin: Margin) {
        stackView.change(margin)
        containerView.change(margin)
        contentView.change(margin)
    }
    
}

public extension UIView {
    func change(_ margin: Margin) {
        if let constraint = constraints.first(where: { $0.firstAttribute == .top || $0.secondAttribute == .top }) {
            constraint.constant = margin.top
        }

        if let constraint = constraints.first(where: { $0.firstAttribute == .bottom || $0.secondAttribute == .bottom }) {
            constraint.constant = -margin.bottom
        }

        if let constraint = constraints.first(where: { $0.firstAttribute == .leading || $0.secondAttribute == .leading }) {
            constraint.constant = margin.left
        }

        if let constraint = constraints.first(where: { $0.firstAttribute == .trailing || $0.secondAttribute == .trailing }) {
            constraint.constant = -margin.right
        }
    }
}
