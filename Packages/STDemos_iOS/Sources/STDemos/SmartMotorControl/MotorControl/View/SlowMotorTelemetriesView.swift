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
    
    let userDescription = UILabel()
    
    var tempRowStackView = UIStackView()
    let tempRowLabel = UILabel()
    let tempValueLabel = UILabel()
    let tempUnitLabel = UILabel()
    
    var speedRefStackView = UIStackView()
    let speedRefRowLabel = UILabel()
    let speedRefValueLabel = UILabel()
    let speedRefUnitLabel = UILabel()
    
    var speedMesaureStackView = UIStackView()
    let speedMeasureRowLabel = UILabel()
    let speedMeasureValueLabel = UILabel()
    let speedMeasureUnitLabel = UILabel()
    
    var busVoltageStackView = UIStackView()
    let busVoltageRowLabel = UILabel()
    let busVoltageValueLabel = UILabel()
    let busVoltageUnitLabel = UILabel()
    
    var neaiStackView = UIStackView()
    let neaiRowLabel = UILabel()
    let neaiClassValueLabel = UILabel()
    let neaiClassUnitLabel = UILabel()
    
    var slowTelemetriesStackView = UIStackView()
    
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let title = UILabel()
        title.text = "Slow Motor Telemetries"
        TextLayout.title2.apply(to: title)
        
        userDescription.text = "To view the data given by the motor, you must start the acquisition via the PLAY button and enable the motor via the START button"
        TextLayout.info.apply(to: userDescription)
        userDescription.numberOfLines = 0
        
        tempRowStackView = buildSlowTelemetriesRow("slow_telemetry_temperature", tempRowLabel, "Temperature", tempValueLabel, "", tempUnitLabel, "")
        tempRowStackView.isHidden = true
       
        speedRefStackView = buildSlowTelemetriesRow("slow_telemetry_speed", speedRefRowLabel, "Speed Ref.", speedRefValueLabel, "", speedRefUnitLabel, "")
        speedRefStackView.isHidden = true
        
        speedMesaureStackView = buildSlowTelemetriesRow("slow_telemetry_speed", speedMeasureRowLabel, "Speed Meas.", speedMeasureValueLabel, "", speedMeasureUnitLabel, "")
        speedMesaureStackView.isHidden = true
        
        busVoltageStackView = buildSlowTelemetriesRow("slow_telemetry_bus_voltage", busVoltageRowLabel, "Bus Voltage", busVoltageValueLabel, "", busVoltageUnitLabel, "")
        busVoltageStackView.isHidden = true
        
        neaiStackView = buildSlowTelemetriesRow("NEAI_logo", neaiRowLabel, "Class:", neaiClassValueLabel, "", neaiClassUnitLabel, "")
        neaiStackView.isHidden = true
        
        slowTelemetriesStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            tempRowStackView,
            buildDivisor(),
            speedRefStackView,
            buildDivisor(),
            speedMesaureStackView,
            buildDivisor(),
            busVoltageStackView,
            buildDivisor(),
            neaiStackView
        ])
        slowTelemetriesStackView.distribution = .fill
        
        slowTelemetriesStackView.isHidden = true
        
        let slowMotorTelemetriesSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            title,
            userDescription,
            slowTelemetriesStackView
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
    
    private func buildSlowTelemetriesRow(_ icon: String, _ telemetryTitleRow: UILabel, _ rowTitlelabel: String, _ valueLabel: UILabel, _ defaultValue: String, _ unitLabel: UILabel, _ unit: String) -> UIStackView {
        let telemetryImage = UIImageView()
        telemetryImage.image = ImageLayout.image(with: icon, in: .module)
        telemetryImage.contentMode = .scaleAspectFit
        telemetryImage.setDimensionContraints(width: 24, height: 24)
        
        telemetryTitleRow.text = rowTitlelabel
        TextLayout.infoBold.apply(to: telemetryTitleRow)
        
        valueLabel.text = defaultValue
        TextLayout.info.apply(to: valueLabel)
        valueLabel.backgroundColor = .systemGray6
        valueLabel.textAlignment = .center
        
        unitLabel.text = unit
        TextLayout.info.apply(to: unitLabel)
        
        let leftSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            telemetryImage,
            telemetryTitleRow
        ])
        
        let rightSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            valueLabel,
            unitLabel
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
