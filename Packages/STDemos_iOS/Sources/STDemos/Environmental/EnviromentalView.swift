//
//  EnviromentalView.swift
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

final class EnviromentalView: UIView {

    let stackView = UIStackView()

    override func awakeFromNib() {
        super.awakeFromNib()

        let scrollView = UIScrollView()

        stackView.axis = .vertical

        addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(stackView)

        stackView.activate(constraints: [
            equal(\.widthAnchor, toView: scrollView, withAnchor: \.widthAnchor)
        ])
    }
}
