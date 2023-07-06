//
//  TabBarItem.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class TabBarItem: UIView {

    let stackView = UIStackView()

    public convenience init(with title: String?, image: UIImage? = nil, callback: @escaping UIControl.UIControlTargetClosure) {
        self.init(frame: .zero)

        tintColor = .white

        stackView.axis = .vertical

        addSubviewAndFit(stackView)

        let actionButton = UIButton(type: .custom)
        actionButton.addAction(for: .touchUpInside,
                               closure: callback)

        addSubviewAndFit(actionButton)

        if let image = image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image

            let view = imageView.embedInView(with: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 4.0, right: 0.0))
            stackView.addArrangedSubview(view)

            view.activate(constraints: [
                equalDimension(\.heightAnchor, to: 28.0)
            ])

        }

        if let title = title {
            let label = UILabel()
            label.text = title
            TextLayout.tabItem
                .alignment(.center)
                .apply(to: label)

            stackView.addArrangedSubview(label)
        }

    }

}
