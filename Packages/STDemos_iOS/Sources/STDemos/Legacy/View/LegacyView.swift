//
//  LegacyView.swift
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

public class LegacyView: UIView {
    
    public var title = UILabel()
    public var legacyDescription = UILabel()
    
    public let badge = UIImageView()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title.text = "Demo is NOT Supported"
        TextLayout.title.apply(to: title)
        
        let appLogo = UIImageView()
        appLogo.image = ImageLayout.image(with: "stblesensorclassicicon", in: .module)
        appLogo.setDimensionContraints(width: 100, height: 100)
        
        let appName = UILabel()
        appName.text = "ST BLE Sensor Classic"
        TextLayout.title2.apply(to: appName)
        
        legacyDescription.text = "This demo is not supported. Please download and use the ST BLE Sensor Classic version.\nClick on the badge below."
        TextLayout.info.apply(to: legacyDescription)
        legacyDescription.numberOfLines = 0
        legacyDescription.textAlignment = .center
        
        badge.image = ImageLayout.image(with: "appstorebadge", in: .module)
        badge.contentMode = .center
        
        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            title,
            appLogo,
            appName,
            legacyDescription,
            badge
        ])
        verticalStackView.alignment = .center
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 8),
            equal(\.trailingAnchor, constant: 8),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(verticalStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
