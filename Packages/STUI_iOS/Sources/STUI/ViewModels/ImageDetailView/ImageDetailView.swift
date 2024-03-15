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
    var disclosureImageView = UIImageView()
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()

    var childView: UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.activate(constraints: [
            equalDimension(\.heightAnchor, to: 40.0),
            equalDimension(\.widthAnchor, to: 40.0)
        ])

        disclosureImageView.activate(constraints: [
            equalDimension(\.widthAnchor, to: 40.0)
        ])

        let textStackView = UIStackView.getVerticalStackView(withSpacing: 5.0,
                                                             views: [
                                                                titleLabel,
                                                                subtitleLabel
                                                             ])

        let headerStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                 views: [
                                                                    imageView,
                                                                    UIView.empty(),
                                                                    disclosureImageView
                                                                 ])

        horizzontalStackView.addArrangedSubview(textStackView)
        horizzontalStackView.addArrangedSubview(UIView.empty())

        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 10.0,
                                                                 views: [
                                                                    headerStackView,
                                                                    horizzontalStackView
                                                                 ])

        addSubviewAndFit(verticalStackView, trailing: 5.0, leading: 5.0)

    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
