//
//  PickerView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class PickerView: UIView {
    var stackView = UIStackView()

    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let actionButton = UIButton()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .horizontal
        stackView.spacing = 20.0

        actionButton.setImage(ImageLayout.Common.chevronDown, for: .normal)

        addSubviewAndFit(stackView)

        let horizzontalStackview = UIStackView.getHorizontalStackView(withSpacing: 4.0,
                                                                 views: [
                                                                    UIView.empty(width: 4.0),
                                                                    valueLabel,
                                                                    actionButton,
                                                                    UIView.empty(width: 4.0)
                                                                 ])

        horizzontalStackview.layer.borderColor = ColorLayout.gray.dark.withAlphaComponent(0.6).cgColor
        horizzontalStackview.layer.borderWidth = 1.0
        horizzontalStackview.layer.cornerRadius = 8.0

        let verticalStackview = UIStackView.getVerticalStackView(withSpacing: 4.0,
                                                                 views: [
                                                                    titleLabel,
                                                                    horizzontalStackview.embedInView(with: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
                                                                 ])

//        stackView.addArrangedSubview(titleLabel)
//        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(verticalStackview)

        stackView.activate(constraints: [
            equalDimension(\.heightAnchor, to: 60.0)
        ])

        actionButton.activate(constraints: [
            equalDimension(\.widthAnchor, to: 30.0),
            equalDimension(\.heightAnchor, to: 30.0)
        ])
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
