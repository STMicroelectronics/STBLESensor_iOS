//
//  PlotViewController.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import Charts

final class PlotViewController: DemoNodeNoViewController<PlotDelegate> {
    
    var selectedFeature: Feature? = nil
    
    let plotFeatureLabel = UILabel()
    let plotFeatureButton = UIButton()
    let plotStartStopButton = UIButton()
    let chart = LineChartView()
    let plotDescription = UILabel()
    
    let yAxisTitleLabel = UILabel()
    let xAxisTitleLabel = UILabel()
    
    let playImg = UIImage(named: "ic_play_arrow_24", in: STUI.bundle, compatibleWith: nil)?.maskWithColor(color: ColorLayout.systemWhite.light)
    
    let stopImg = UIImage(named: "ic_stop_24", in: STUI.bundle, compatibleWith: nil)?.maskWithColor(color: ColorLayout.systemWhite.light)
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.plot.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        plotFeatureLabel.text = "None"
        TextLayout.text.apply(to: plotFeatureLabel)
        plotFeatureLabel.numberOfLines = 0
        
        let arrowDownImg = UIImage(systemName: "chevron.down")?.maskWithColor(color: ColorLayout.primary.light)
        plotFeatureButton.setImage(arrowDownImg, for: .normal)
        
        plotStartStopButton.setImage(playImg, for: .normal)
        plotStartStopButton.setDimensionContraints(width: 65, height: 45)
        plotStartStopButton.backgroundColor = ColorLayout.primary.light
        plotStartStopButton.contentMode = .scaleAspectFit
        
        TextLayout.info.apply(to: plotDescription)
        
        let horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            plotFeatureLabel,
            plotFeatureButton,
            UIView(),
            plotStartStopButton
        ])
        horizontalSV.distribution = .fill
        
        TextLayout.info.apply(to: yAxisTitleLabel)
        TextLayout.info.apply(to: xAxisTitleLabel)
        
        let yAxisTitleLabelSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            yAxisTitleLabel,
            UIView()
        ])
        yAxisTitleLabelSV.distribution = .fill
        
        let xAxisTitleLabelSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            xAxisTitleLabel
        ])
        xAxisTitleLabelSV.distribution = .fill
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            horizontalSV,
            yAxisTitleLabelSV,
            chart,
            xAxisTitleLabelSV,
            plotDescription
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let featureSelectorTap = UITapGestureRecognizer(target: self, action: #selector(featureSelectorTapped(_:)))
        plotFeatureButton.addGestureRecognizer(featureSelectorTap)
        
        let startStopTap = UITapGestureRecognizer(target: self, action: #selector(startStopTapped(_:)))
        plotStartStopButton.addGestureRecognizer(startStopTap)
        
        setUpCharts()
    }
    
    private func setUpCharts(){
        chart.rightAxis.enabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        chart.xAxis.drawLabelsEnabled = false
        
        chart.leftAxis.drawZeroLineEnabled = true
        chart.rightAxis.drawZeroLineEnabled = true
        
        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        chart.chartDescription.enabled=false
        chart.isMultipleTouchEnabled=false
        chart.noDataText = "Select Feature"
        
        let legend = chart.legend
        legend.drawInside = false
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .bottom
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            if let selectedFeature = self?.selectedFeature {
                if feature.type.uuid == selectedFeature.type.uuid {
                    self?.presenter.updatePlot(with: sample)
                }
            }
        }
    }
    
}

extension PlotViewController {
    @objc
    func startStopTapped(_ sender: UITapGestureRecognizer) {
        presenter.startStopPlotting()
    }
    
    @objc
    func featureSelectorTapped(_ sender: UITapGestureRecognizer) {
        presenter.selectFeature()
    }
}
