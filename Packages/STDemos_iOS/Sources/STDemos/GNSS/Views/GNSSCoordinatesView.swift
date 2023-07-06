//
//  GNSSCoordinatesView.swift
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

class GNSSCoordinatesView: UIView {
    
    let latitude = UILabel()
    let longitude = UILabel()
    let altitude = UILabel()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gpsImage = UIImageView()
        gpsImage.image = ImageLayout.image(with: "GNSS_gps", in: .module)
        gpsImage.setDimensionContraints(width: 50, height: 50)
        
        let latitudeLabel = UILabel()
        latitudeLabel.text = "Latitude"
        TextLayout.info.apply(to: latitudeLabel)
        
        latitude.text = "0.0 [N]"
        TextLayout.info.apply(to: latitude)
        
        let latitudeSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            latitudeLabel,
            UIView(),
            latitude
        ])
        
        let longitudeLabel = UILabel()
        longitudeLabel.text = "Longitude"
        TextLayout.info.apply(to: longitudeLabel)
        
        longitude.text = "0.0 [E]"
        TextLayout.info.apply(to: longitude)
        
        let longitudeSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            longitudeLabel,
            UIView(),
            longitude
        ])
        
        let altitudeLabel = UILabel()
        altitudeLabel.text = "Altitude"
        TextLayout.info.apply(to: altitudeLabel)
        
        altitude.text = "0.0 [m]"
        TextLayout.info.apply(to: altitude)
        
        let altitudeSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            altitudeLabel,
            UIView(),
            altitude
        ])
        
        let gpsLabelSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            latitudeSV,
            longitudeSV,
            altitudeSV
        ])
        gpsLabelSV.distribution = .fillEqually
        
        let gpsIconSV = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            UIView(),
            gpsImage,
            UIView()
        ])
        gpsIconSV.distribution = .equalCentering
        
        let gpsSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            gpsIconSV,
            gpsLabelSV
        ])
        gpsSV.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])
        stackView.setDimensionContraints(height: 80.0)
        stackView.addArrangedSubview(gpsSV)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
