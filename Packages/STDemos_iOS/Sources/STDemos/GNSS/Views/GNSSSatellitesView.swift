//
//  GNSSSatellitesView.swift
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

class GNSSSatellitesView: UIView {
    
    let satellites = UILabel()
    let signal = UILabel()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let satelliteImage = UIImageView()
        satelliteImage.image = ImageLayout.image(with: "GNSS_satellite", in: .module)
        satelliteImage.setDimensionContraints(width: 50, height: 50)
        
        let satellitesLabel = UILabel()
        satellitesLabel.text = "Satellites"
        TextLayout.info.apply(to: satellitesLabel)
        
        satellites.text = "0 [Num]"
        TextLayout.info.apply(to: satellites)
        
        let satellitesLabelSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            satellitesLabel,
            UIView(),
            satellites
        ])
        
        let signalLabel = UILabel()
        signalLabel.text = "Signal"
        TextLayout.info.apply(to: signalLabel)
        
        signal.text = "0 [dB-Hz]"
        TextLayout.info.apply(to: signal)
        
        let signalSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            signalLabel,
            UIView(),
            signal
        ])
        
        let satellitesInfoSV  = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            satellitesLabelSV,
            signalSV
        ])
        satellitesInfoSV.distribution = .fillEqually
        
        let satellitesSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            satelliteImage,
            satellitesInfoSV
        ])
        satellitesSV.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(satellitesSV)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
