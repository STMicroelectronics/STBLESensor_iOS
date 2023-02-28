//
//  ExpandableSectionView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit

class ExpandableSectionView: BaseView {
    let imageView = UIImageView()
    let label = UILabel()
    
    override func configureView() {
        backgroundColor = .white
        
        let stackView = UIStackView.getHorizontalStackView(withSpacing: 4, views: [imageView, label])
        imageView.setDimensionContraints(width: 33, height: 33)
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = currentTheme.color.primary
        imageView.tintColor = currentTheme.color.primary
        addSubviewAndFit(stackView, top: 16, trailing: 16, bottom: 16, leading: 16)
    }
}
