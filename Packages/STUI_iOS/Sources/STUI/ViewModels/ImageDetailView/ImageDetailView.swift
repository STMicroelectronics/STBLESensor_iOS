//
//  ImageDetailView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class ImageDetailView: UIView {
    let horizzontalStackView = UIStackView()

    var imageView = UIImageView()
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()

    var childView: UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        horizzontalStackView.axis = .horizontal
        horizzontalStackView.spacing = 10.0

        horizzontalStackView.activate(constraints: [
            equalDimension(\.heightAnchor, to: 60.0)
        ])

        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical

        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)

        titleLabel.activate(constraints: [
            equal(\.heightAnchor, toView: subtitleLabel, withAnchor: \.heightAnchor)
        ])

        addSubviewAndFit(horizzontalStackView, trailing: 20.0, leading: 20.0)

        horizzontalStackView.addArrangedSubview(imageView)

        imageView.activate(constraints: [
            equalDimension(\.widthAnchor, to: 60.0)
        ])

        horizzontalStackView.addArrangedSubview(verticalStackView)

    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
