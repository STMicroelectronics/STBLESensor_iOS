//
//  ObjectView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

open class ObjectView: UIView {

    var objectLabel = UILabel()
    var stackView = UIStackView()
    var childrenStackView = UIStackView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .vertical
        stackView.spacing = 5.0

        childrenStackView.axis = .vertical
        childrenStackView.spacing = 5.0

        addSubviewAndFit(stackView)

        stackView.addArrangedSubview(objectLabel)

        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal

        stackView.addArrangedSubview(horizontalStackView)

        let emptyView = UIView()
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.activate(constraints: [
            equalDimension(\.widthAnchor, to: 40.0)
        ])

        horizontalStackView.addArrangedSubview(emptyView)
        horizontalStackView.addArrangedSubview(childrenStackView)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
