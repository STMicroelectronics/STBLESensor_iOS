//
//  PlotDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 12/10/2026.
//
import SwiftUI
import STBlueSDK
import DGCharts

class PlotDemoViewModel: ObservableObject {
    
    @Published var listOfFeatures: [Feature?] = [nil]
    @Published var selectedFeature: Feature? = nil
    
    @Published var dataSets: [LineChartDataSet] = []
    
    @Published var plotStatus: PlotStatus = .idle
    
    @Published var sampleDescription: String = ""
    @Published var xAxisTitleLabel: String = ""
    @Published var yAxisTitleLabel: String = ""
    
    var plotEntries: [PlotEntry] = []
    
    private let DefaultDisplayWindowTimeSecond = UInt64(5)
    
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    func updatePlotEntry(feature: any STBlueSDK.Feature,sample: (any STBlueSDK.AnyFeatureSample)?) {
        guard let sample = sample else { return }
        
        //Keep only the samples of the selected feature
        if let selectedFeature = selectedFeature {
            if feature.type.uuid != selectedFeature.type.uuid {
                return
            }
        }
        
        if let plotEntry = sample.toPlotEntry(sample: sample),
           let plotDesc = sample.toPlotDescription(sample: sample),
           let plotConf = sample.toPlotConfiguration(sample: sample) {
            
            if let plotAxisTitle = sample.toPlotAxisLabel(sample: sample) {
                yAxisTitleLabel = "[Y] \(plotAxisTitle)"
            } else {
                yAxisTitleLabel = "[Y]"
            }
            
            if(xAxisTitleLabel.isEmpty) {
                xAxisTitleLabel = "[X] Time"
            }
            
            sampleDescription = plotDesc
            
            
            if let lastElementTime = plotEntries.last?.x,  let firstElementTime = plotEntries.first?.x {
                if((lastElementTime - firstElementTime) > DefaultDisplayWindowTimeSecond*1000) {
                    let timeFirstElementToVisualize = lastElementTime - (DefaultDisplayWindowTimeSecond*1000)
                    plotEntries.removeAll(where: {$0.x < timeFirstElementToVisualize})
                }
            }
            
            plotEntries.append(plotEntry)
            
            var localDataSets: [LineChartDataSet] = []
            
            for i in 0..<plotEntry.y.count {
                let currentConf = plotConf[i]
                var currentChartDataEntries: [ChartDataEntry] = []
                plotEntries.forEach { plotEntry in
                    currentChartDataEntries.append(ChartDataEntry(x: Double(plotEntry.x), y: Double(plotEntry.y[i])))
                }
                localDataSets.append(buildChartDataSet(dataEntries: currentChartDataEntries, conf: currentConf))
            }
            dataSets = localDataSets
        }
    }
    
    func loadFeatures (node: Node) {
        let supportedDemoFeature = node.characteristics.features(with: Demo.plot.features)
        supportedDemoFeature.forEach { feature in
            listOfFeatures.append(feature)
        }
    }
    
    func switchPlotStatus() {
        plotStatus = plotStatus == .idle ? .plotting : .idle
        
        switch plotStatus {
        case .idle:
            if let feature = selectedFeature {
                BlueManager.shared.disableNotifications(for: node, feature: feature)
            }
            break
        case .plotting:
            plotEntries.removeAll()
            dataSets.removeAll()
            sampleDescription = ""
            yAxisTitleLabel = ""
            if let feature = selectedFeature {
                BlueManager.shared.enableNotifications(for: node, feature: feature)
            }
            break
        }
    }
    
    func clearFeatures() {
        listOfFeatures.removeAll()
        listOfFeatures.append(nil)
        unSelectFeature()
        plotStatus = .idle
        plotEntries.removeAll()
        dataSets.removeAll()
        sampleDescription = ""
        xAxisTitleLabel = ""
        yAxisTitleLabel = ""
    }
    
    func selectFeature(_ feature: Feature) {
        selectedFeature = feature
    }
    
    func unSelectFeature() {
        selectedFeature = nil
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
        //view.chart.leftAxis.forceLabelsEnabled = true
        return line
    }
}
