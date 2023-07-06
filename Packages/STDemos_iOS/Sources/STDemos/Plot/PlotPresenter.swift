//
//  PlotPresenter.swift
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

final class PlotPresenter: DemoPresenter<PlotViewController> {
    var plotEntries: [PlotEntry] = []
    var supportedDemoFeature: [Feature] = []
    var plotStatus: PlotStatus = .idle
}

// MARK: - PlotViewControllerDelegate
extension PlotPresenter: PlotDelegate {

    func load() {
        demo = .plot

        supportedDemoFeature = param.node.characteristics.features(with: Demo.plot.features)
        
        view.configureView()
    }
    
    func updatePlot(with sample: AnyFeatureSample?) {
        if let plotEntry = sample?.toPlotEntry(sample: sample),
           let plotDesc = sample?.toPlotDescription(sample: sample),
           let plotConf = sample?.toPlotConfiguration(sample: sample) {
            
            view.plotDescription.text = plotDesc
            
            if plotEntries.count > 99 {
                plotEntries.removeFirst()
            }
            
            plotEntries.append(plotEntry)
            
            var dataSets: [LineChartDataSet] = []
            
            for i in 0..<plotEntry.y.count {
                let currentConf = plotConf[i]
                var currentChartDataEntries: [ChartDataEntry] = []
                plotEntries.forEach { plotEntry in
                    currentChartDataEntries.append(ChartDataEntry(x: Double(plotEntry.x), y: Double(plotEntry.y[i])))
                }
                dataSets.append(buildChartDataSet(dataEntries: currentChartDataEntries, conf: currentConf))
            }
            
            DispatchQueue.main.async {
                self.view.chart.data = LineChartData(dataSets: dataSets)
                self.view.chart.notifyDataSetChanged()
            }
        }
    }
    
    func selectFeature() {
        let actions: [UIAlertAction] = supportedDemoFeature.map { item in
            let itemName = item.name.replacingOccurrences(of: "Feature", with: "")
            return UIAlertAction.genericButton(itemName) { [weak self] _ in
                self?.view.selectedFeature = item
                self?.view.plotFeatureLabel.text = itemName
            }
        }
        UIAlertController.presentAlert(from: view, title: nil, actions: actions)
    }
    
    func startStopPlotting() {
        if plotStatus == .idle {
            if let feature = view.selectedFeature {
                BlueManager.shared.enableNotifications(for: param.node, feature: feature)
                plotStatus = .plotting
                self.view.plotStartStopButton.setImage(self.view.stopImg, for: .normal)
                disableFeatureSelectionInteraction()
            }
        } else {
            enableFeatureSelectionInteraction()
            if let feature = view.selectedFeature {
                resetChart()
                BlueManager.shared.disableNotifications(for: param.node, feature: feature)
                plotStatus = .idle
                self.view.plotStartStopButton.setImage(self.view.playImg, for: .normal)
            }
        }
    }
    
    private func buildChartDataSet(dataEntries: [ChartDataEntry], conf: LineConfig) -> LineChartDataSet {
        let line = LineChartDataSet(entries: dataEntries, label: conf.name)
        line.drawCirclesEnabled = false
        line.drawIconsEnabled = false
        line.drawValuesEnabled = false
        line.setDrawHighlightIndicators(false)
        line.lineWidth = 1.0
        line.setColor(conf.color)
        line.mode = .linear
        view.chart.leftAxis.forceLabelsEnabled = true
        return line
    }
    
    private func resetChart() {
        plotEntries = []
        self.view.chart.lineData?.dataSets.removeAll()
        self.view.chart.notifyDataSetChanged()
        self.view.plotDescription.text = ""
    }
    
    private func disableFeatureSelectionInteraction() {
        self.view.plotFeatureLabel.isUserInteractionEnabled = false
        self.view.plotFeatureButton.isUserInteractionEnabled = false
        self.view.plotFeatureLabel.layer.opacity = 0.4
        self.view.plotFeatureButton.layer.opacity = 0.4
    }
    
    private func enableFeatureSelectionInteraction() {
        self.view.plotFeatureLabel.isUserInteractionEnabled = true
        self.view.plotFeatureButton.isUserInteractionEnabled = true
        self.view.plotFeatureLabel.layer.opacity = 1.0
        self.view.plotFeatureButton.layer.opacity = 1.0
    }
}
