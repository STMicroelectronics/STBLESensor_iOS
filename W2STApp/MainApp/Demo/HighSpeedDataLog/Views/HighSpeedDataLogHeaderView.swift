//
//  HighSpeedDataLogHeaderView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 12/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK_Gui

class HighSpeedDataLogHeaderView: BaseView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let cpuUsage = TitleIconView()
    let battery = TitleIconView()
    
    override func configureView() {
        super.configureView()
        
        backgroundColor = .white
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.tintColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.tintColor = .gray
        
        let titlesStack = UIStackView.getVerticalStackView(withSpacing: 2, views: [titleLabel, subtitleLabel])
        let stackView = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            cpuUsage,
            titlesStack,
            battery
        ])
        
        addSubviewAndFit(stackView, top: 8, trailing: 8, bottom: 8, leading: 8)
    }
}
