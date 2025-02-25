//
//  MedicalView.swift
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
import DGCharts
import STBlueSDK

class MedicalView: UIView {
    
    let chart = LineChartView()
    
    let yAxisTitleLabel = UILabel()
    //let xAxisTitleLabel = UILabel()
    
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        TextLayout.info.apply(to: yAxisTitleLabel)
        //TextLayout.info.apply(to: xAxisTitleLabel)
        
        
        let yAxisTitleLabelSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            yAxisTitleLabel
        ])
        yAxisTitleLabelSV.distribution = .fill
        
//        let xAxisTitleLabelSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
//            UIView(),
//            xAxisTitleLabel
//        ])
//        xAxisTitleLabelSV.distribution = .fill
        
        //xAxisTitleLabel.text = "[X] Time"
        
        let medicalSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            yAxisTitleLabelSV,
            chart,
//            xAxisTitleLabelSV
        ])
        medicalSV.distribution = .fill
        
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 8.0),
            equal(\.trailingAnchor, constant: -8.0),
            equal(\.topAnchor, constant: 8),
            equal(\.bottomAnchor, constant: -8)
        ])
        stackView.setDimensionContraints(height: 200.0)
        stackView.addArrangedSubview(medicalSV)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpChart(sigType: MedicalSignalType? = nil) {
        chart.rightAxis.enabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        if sigType != nil {
            chart.xAxis.drawLabelsEnabled = sigType!.showXvalues
        } else {
            chart.xAxis.drawLabelsEnabled = false
        }
        
        chart.leftAxis.drawZeroLineEnabled = true
        chart.rightAxis.drawZeroLineEnabled = true
        
        if sigType?.nLabels != nil {
            if sigType!.nLabels != 0 {
                chart.leftAxis.labelCount = sigType!.nLabels
            }
        }
        
        if sigType != nil {
            chart.setScaleEnabled(sigType!.isAutoscale)
            
            if !sigType!.isAutoscale {
                chart.leftAxis.axisMaximum = Double(sigType!.maxGraphValue)
                chart.leftAxis.axisMinimum = Double(sigType!.minGraphValue)
            }
        }
        
        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        chart.chartDescription.enabled=false
        chart.isMultipleTouchEnabled=false
        chart.noDataText = "Start MedSig"
        
        if sigType != nil {
            let legend = chart.legend
            
            if sigType!.showLegend {
                legend.enabled = true
                legend.drawInside = false
                legend.horizontalAlignment = .right
                legend.verticalAlignment = .bottom
            } else {
                legend.enabled = false
            }
        }
    }
    
    func resetZoom() {
        chart.fitScreen()
    }
}

