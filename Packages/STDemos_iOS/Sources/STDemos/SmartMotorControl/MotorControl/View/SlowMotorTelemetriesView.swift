//
//  SlowMotorTelemetriesView.swift
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

class SlowMotorTelemetriesView: UIView {
    
    let tempValueLabel = UILabel()
    let speedRefValueLabel = UILabel()
    let speedMeasureValueLabel = UILabel()
    let busVoltageValueLabel = UILabel()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let title = UILabel()
        title.text = "Slow Motor Telemetries"
        TextLayout.title2.apply(to: title)
        
        let description = UILabel()
        description.text = "To view the data given by the motor, you must start the acquisition via the PLAY button and enable the motor via the START button"
        TextLayout.info.apply(to: description)
        description.numberOfLines = 0
        
        let tempRow = buildSlowTelemetriesRow("slow_telemetry_temperature", "Temperature", tempValueLabel, "63", "°C")
       
        let speedRefRow = buildSlowTelemetriesRow("slow_telemetry_speed", "Speed Ref.", speedRefValueLabel, "20.2", "krpm")
        
        let speedMeasRow = buildSlowTelemetriesRow("slow_telemetry_speed", "Speed Meas.", speedMeasureValueLabel, "20.0", "krpm")
        
        let busVoltageRow = buildSlowTelemetriesRow("slow_telemetry_bus_voltage", "Bus Voltage", busVoltageValueLabel, "47.3", "V")
        
        let slowMotorTelemetriesSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            title,
            description,
            tempRow,
            buildDivisor(),
            speedRefRow,
            buildDivisor(),
            speedMeasRow,
            buildDivisor(),
            busVoltageRow
        ])
        slowMotorTelemetriesSV.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 0.0),
            equal(\.trailingAnchor, constant: -0.0),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(slowMotorTelemetriesSV)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSlowTelemetriesRow(_ icon: String, _ label: String, _ valueLabel: UILabel, _ defaultValue: String, _ unit: String) -> UIStackView {
        let telemetryImage = UIImageView()
        telemetryImage.image = ImageLayout.image(with: icon, in: .module)
        telemetryImage.contentMode = .scaleAspectFit
        telemetryImage.setDimensionContraints(width: 24, height: 24)
        
        let telemetryLabel = UILabel()
        telemetryLabel.text = label
        TextLayout.infoBold.apply(to: telemetryLabel)
        
        valueLabel.text = defaultValue
        TextLayout.info.apply(to: valueLabel)
        valueLabel.backgroundColor = .systemGray6
        valueLabel.textAlignment = .center
        
        let telemetryUnit = UILabel()
        telemetryUnit.text = unit
        TextLayout.info.apply(to: telemetryUnit)
        
        let leftSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            telemetryImage,
            telemetryLabel,
            
        ])
        
        let rightSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            valueLabel,
            telemetryUnit
        ])
        
        let sv = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            leftSV,
            rightSV
        ])
        sv.distribution = .fillEqually
        
        return sv
    }
    
    private func buildDivisor() -> UIView {
        let divisor = UIView()
        divisor.backgroundColor = ColorLayout.primary.auto
        divisor.setDimensionContraints(height: 1)
        return divisor
    }
}
