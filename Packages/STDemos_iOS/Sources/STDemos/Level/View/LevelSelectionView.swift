//
//  LevelSelectionView.swift
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

class LevelSelectionView: UIView {
    
    let selectionLabel = UILabel()
    let selectionButton = UIButton()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        TextLayout.title2.apply(to: selectionLabel)

        selectionButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        selectionButton.setTitle(" ", for: .normal)
        
        let horizontalStackView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            selectionLabel,
            UIView(),
            selectionButton
        ])
        horizontalStackView.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 8),
            equal(\.bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(horizontalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
