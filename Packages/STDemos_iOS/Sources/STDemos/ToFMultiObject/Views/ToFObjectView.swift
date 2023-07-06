//
//  ToFObjectView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STUI

class ToFObjectView: UIView {
    
    let objectsImage = UIImageView()
    let objectDescription = UILabel()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        objectsImage.image = ImageLayout.image(with: "TOF_search", in: .module)
        objectsImage.setDimensionContraints(width: 48, height: 48)
        
        TextLayout.info.apply(to: objectDescription)

        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            objectsImage,
            UIView(),
            objectDescription
        ])
        horizontalStackView.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(horizontalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
