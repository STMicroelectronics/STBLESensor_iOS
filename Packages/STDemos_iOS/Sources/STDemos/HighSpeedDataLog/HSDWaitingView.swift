//
//  HSDWaitingView.swift
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

public class HSDWaitingView: UIView {

    let textLabel = UILabel()
    let activityIndicatorView = UIActivityIndicatorView()

    public var isVisible: Bool = false {
        didSet {
            isHidden = !isVisible
            isUserInteractionEnabled = isVisible
        }
    }

    public convenience init(text: String) {
        self.init(frame: .zero)

        TextLayout.info.apply(to: textLabel)

        textLabel.text = text
        textLabel.textAlignment = .center

        let stackView = UIStackView.getVerticalStackView(withSpacing: 10.0,
                                                         views: [
                                                            activityIndicatorView,
                                                            textLabel
                                                         ])

        addSubview(stackView,
                   constraints: [
                    equal(\.leadingAnchor),
                    equal(\.centerXAnchor),
                    equal(\.centerYAnchor)
                   ])

        activityIndicatorView.startAnimating()

        backgroundColor = .white
    }

    public func update(text: String) {
        textLabel.text = text
    }
}
