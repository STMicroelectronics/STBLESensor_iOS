//
//  HSDCharTypeView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 14/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit

class HSDCharTypeView: BaseView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconImageView = UIImageView()
    
    var model: HSDOptionModel! {
        didSet {
            updateUI()
        }
    }
    
    override func configureView() {
        super.configureView()
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .gray
        
        valueLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        iconImageView.setDimensionContraints(width: 16, height: 16)
        iconImageView.image = UIImage.namedFromGUI("icon_arrow_fill_down")
        
        let valueContainerView = UIView()
        valueContainerView.addSubviewAndFit(valueLabel, top: 8, trailing: 8, bottom: 8, leading: 16)
        
        let hstack = UIStackView.getHorizontalStackView(withSpacing: 4, views: [valueContainerView, iconImageView])
        let vstack = UIStackView.getVerticalStackView(withSpacing: 4, views: [titleLabel, hstack])
        hstack.alignment = .center
        vstack.alignment = .fill
        
        addSubviewAndFit(vstack)
    }
    
    override func updateUI() {
        super.updateUI()
        
        if let unit = model.unit {
            titleLabel.text = model.name.localizedFromGUI + " ( \(unit) )"
        } else {
            titleLabel.text = model.name.localizedFromGUI
        }
        valueLabel.text = String(model.selected)
    }
}
