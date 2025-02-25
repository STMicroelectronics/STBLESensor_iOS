//
//  MedicalSignalPresenter.swift
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
import STCore
import DGCharts

final class MedicalSignalPresenter: DemoPresenter<MedicalSignalViewController> {
    var plot16BitEntries: [PlotEntry] = []
    var plot24BitEntries: [PlotEntry] = []
    var feature16bit: Feature? = nil
    var feature24bit: Feature? = nil
    
    var plot16BitStatus: PlotStatus = .idle
    var plot24BitStatus: PlotStatus = .idle
    
    var prevMed16Info: MedicalInfo? = nil
    var plotConf16Bit: [LineConfig] = []
    var firstInternalTimeStamp16Bit: Int? = nil
    
    var prevMed24Info: MedicalInfo? = nil
    var plotConf24Bit: [LineConfig] = []
    var firstInternalTimeStamp24Bit: Int? = nil
    
    //All the Medical Signals have like maximum 4 channels
    let colors: [UIColor] = [ColorLayout.blue.light, ColorLayout.red.light, ColorLayout.green.light, ColorLayout.ochre.light]
    
    var featuresRawControlled: Feature? = nil
    var featuresPnpL: Feature? = nil
    
    var firmwareDB: Firmware?
}

extension MedicalSignalPresenter: MedicalSignalDelegate {
    
    func requestPnpLStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,  maxWriteLength: 20, to: self.param.node)
    }
    
    func disableAllNotifications() {
        if let feature = feature16bit  {
            BlueManager.shared.disableNotifications(for: param.node, feature: feature)
        }
        
        if let feature = feature24bit  {
            BlueManager.shared.disableNotifications(for: param.node, feature: feature)
        }
        
        if let feature = featuresRawControlled  {
            BlueManager.shared.disableNotifications(for: param.node, feature: feature)
        }
        
        if let feature = featuresPnpL  {
            BlueManager.shared.disableNotifications(for: param.node, feature: feature)
        }
    }
    
    func load() {
        demo = .medicalSignal

        feature16bit = param.node.characteristics.first(with: MedicalSignal16BitFeature.self)
        if feature16bit != nil {
            view.feature16Bit = feature16bit
        }
        
        feature24bit = param.node.characteristics.first(with: MedicalSignal24BitFeature.self)
        if feature24bit != nil {
            view.feature24Bit = feature24bit
        }
        
        
        featuresPnpL = param.node.characteristics.first(with: PnPLFeature.self)
        
        if featuresPnpL != nil  {
            view.featuresPnpL = featuresPnpL
            
            //Retrieve the Firmware Model from Firmware DB
            if let catalogService: CatalogService = Resolver.shared.resolve(),
               let catalog = catalogService.catalog {
                firmwareDB = catalog.v2Firmware(with: param.node)
            }
            
            BlueManager.shared.enableNotifications(for: param.node, feature: featuresPnpL!)
            
            requestPnpLStatusUpdate()
            
        }
        
        featuresRawControlled = param.node.characteristics.first(with: RawPnPLControlledFeature.self)
        
        
        if featuresRawControlled != nil {
            view.featuresRawControlled = featuresRawControlled
            
            BlueManager.shared.enableNotifications(for: param.node, feature: featuresRawControlled!)
        }
        
        view.configureView()
        
        //Autostart the features if they are present
        if feature16bit != nil {
            startStop16BitPlotting()
        }
        
        if feature24bit != nil {
            startStop24BitPlotting()
        }
    }
    
    func update16BitPlot(with sample: AnyFeatureSample?) {
        
        if let sample = sample as? FeatureSample<MedicalInfo> {
            if let sigType = sample.data?.sigType.value!,
               let internalTimeStamp = sample.data?.internalTimeStamp.value!{
                
                if prevMed16Info == nil {
                    //Configure the plot
                    for i in 0..<sigType.numberOfSignals {
                        if sigType.signalLabels.isEmpty {
                            plotConf16Bit.append(LineConfig(name: "S_\(i)", color: colors[i]))
                        } else {
                            plotConf16Bit.append(LineConfig(name: sigType.signalLabels[i], color: colors[i]))
                        }
                    }
                    
                    if let plotAxisTitle = sigType.yMeasurementUnit {
                        view.medical16View.yAxisTitleLabel.text = "\(sigType.description) [\(plotAxisTitle)]"
                    } else {
                        view.medical16View.yAxisTitleLabel.text = "\(sigType.description)"
                    }
                                        
                    //Save the data for draving at next sample
                    prevMed16Info = sample.data
                    
                    view.medical16View.setUpChart(sigType: sigType)
                    
                    firstInternalTimeStamp16Bit = internalTimeStamp
                    
                } else {
                 
                    //Compute the delta Time respect the previous Sample
                    let timeDiff = internalTimeStamp - prevMed16Info!.internalTimeStamp.value!
                    
                    //This is the delta time between Samples
                    let deltaBetweenSample = timeDiff * prevMed16Info!.sigType.value!.numberOfSignals / prevMed16Info!.values.value!.count
                    
                    //Fill the data..
                    if sigType.numberOfSignals > 1 {
                        let valuesChuncked = prevMed16Info!.values.value!.splitByChunk(sigType.numberOfSignals)
                        
                        for index in 0..<valuesChuncked.count {
                            let currTime = prevMed16Info!.internalTimeStamp.value! + deltaBetweenSample * index - firstInternalTimeStamp16Bit!
                            
                            var y:[Float]=[]
                            for signal in 0..<sigType.numberOfSignals {
                                y.append(Float(valuesChuncked[index][signal]))
                            }
                            
                            let plotEntry = PlotEntry( x: UInt64(currTime), y: y)
                            
                            plot16BitEntries.append(plotEntry)
                            
                            var dataSets: [LineChartDataSet] = []
                            
                            for i in 0..<plotEntry.y.count {
                               let currentConf = plotConf16Bit[i]
                               var currentChartDataEntries: [ChartDataEntry] = []
                               plot16BitEntries.forEach { plotEntry in
                                   currentChartDataEntries.append(ChartDataEntry(x: Double(plotEntry.x), y: Double(plotEntry.y[i])))
                               }
                               dataSets.append(buildChartDataSet16Bit(dataEntries: currentChartDataEntries, conf: currentConf, sigType: sigType))
                           }
           
                           DispatchQueue.main.async {
                               self.view.medical16View.chart.data = LineChartData(dataSets: dataSets)
                               self.view.medical16View.chart.notifyDataSetChanged()
                           }
                            
                        }
                        
                    } else {
                        for index in 0..<prevMed16Info!.values.value!.count {
                            let currTime = prevMed16Info!.internalTimeStamp.value! + deltaBetweenSample * index - firstInternalTimeStamp16Bit!
                            
                            let plotEntry = PlotEntry( x: UInt64(currTime), y: [Float(prevMed16Info!.values.value![index])])
                            plot16BitEntries.append(plotEntry)
                            
                            var dataSets: [LineChartDataSet] = []
                            
                            for i in 0..<plotEntry.y.count {
                               let currentConf = plotConf16Bit[i]
                               var currentChartDataEntries: [ChartDataEntry] = []
                               plot16BitEntries.forEach { plotEntry in
                                   currentChartDataEntries.append(ChartDataEntry(x: Double(plotEntry.x), y: Double(plotEntry.y[i])))
                               }
                               dataSets.append(buildChartDataSet16Bit(dataEntries: currentChartDataEntries, conf: currentConf, sigType: sigType))
                           }
           
                           DispatchQueue.main.async {
                               self.view.medical16View.chart.data = LineChartData(dataSets: dataSets)
                               self.view.medical16View.chart.notifyDataSetChanged()
                           }
                            
                        }
                    }
                    
                    if plot16BitEntries.count > 1000 {
                        plot16BitEntries.removeFirst(plot16BitEntries.count - 1000)
                    }
                    
                    if let lastElementTime = plot16BitEntries.last?.x {
                        if let safeLastElementTime = Int(exactly: lastElementTime) {
                            let timeLastElementToVisualize = safeLastElementTime - (sigType.displayWindowTimeSecond*1000)
                            plot16BitEntries.removeAll(where: {$0.x < timeLastElementToVisualize})
                        }
                    }
                    
                    //Save the data for draving at next sample
                    prevMed16Info = sample.data
                }
                
            }
        }
    }
    
    private func buildChartDataSet16Bit(dataEntries: [ChartDataEntry], conf: LineConfig, sigType: MedicalSignalType) -> LineChartDataSet {
        let line = LineChartDataSet(entries: dataEntries, label: conf.name)
        
        if sigType.cubicInterpolation {
            line.mode = .cubicBezier
            line.cubicIntensity = 0.2
        }
        
        line.drawCirclesEnabled = false
        line.drawIconsEnabled = false
        line.drawValuesEnabled = false
        line.setDrawHighlightIndicators(false)
        line.lineWidth = 1.0
        line.setColor(conf.color)
        line.mode = .linear
        view.medical16View.chart.leftAxis.forceLabelsEnabled = true
        return line
    }
    
    
    func update24BitPlot(with sample: AnyFeatureSample?) {
        
        if let sample = sample as? FeatureSample<MedicalInfo> {
            if let sigType = sample.data?.sigType.value!,
               let internalTimeStamp = sample.data?.internalTimeStamp.value!{
                
                if prevMed24Info == nil {
                    //Configure the plot
                    for i in 0..<sigType.numberOfSignals {
                        if sigType.signalLabels.isEmpty {
                            plotConf24Bit.append(LineConfig(name: "S_\(i)", color: colors[i]))
                        } else {
                            plotConf24Bit.append(LineConfig(name: sigType.signalLabels[i], color: colors[i]))
                        }
                    }
                    
                    if let plotAxisTitle = sigType.yMeasurementUnit {
                        view.medical24View.yAxisTitleLabel.text = "\(sigType.description) [\(plotAxisTitle)]"
                    } else {
                        view.medical24View.yAxisTitleLabel.text = "\(sigType.description)"
                    }
                    
                    
                    //Save the data for draving at next sample
                    prevMed24Info = sample.data
                    
                    view.medical24View.setUpChart(sigType: sigType)
                    
                    firstInternalTimeStamp24Bit = internalTimeStamp
                    
                } else {
                 
                    //Compute the delta Time respect the previous Sample
                    let timeDiff = internalTimeStamp - prevMed24Info!.internalTimeStamp.value!
                    
                    //This is the delta time between Samples
                    let deltaBetweenSample = timeDiff * prevMed24Info!.sigType.value!.numberOfSignals / prevMed24Info!.values.value!.count
                    
                    //Fill the data..
                    if sigType.numberOfSignals > 1 {
                        let valuesChuncked = prevMed24Info!.values.value!.splitByChunk(sigType.numberOfSignals)
                        
                        for index in 0..<valuesChuncked.count {
                            let currTime = prevMed24Info!.internalTimeStamp.value! + deltaBetweenSample * index - firstInternalTimeStamp24Bit!
                            
                            var y:[Float]=[]
                            for signal in 0..<sigType.numberOfSignals {
                                y.append(Float(valuesChuncked[index][signal]))
                            }
                            
                            let plotEntry = PlotEntry( x: UInt64(currTime), y: y)
                            
                            plot24BitEntries.append(plotEntry)
                            
                            var dataSets: [LineChartDataSet] = []
                            
                            for i in 0..<plotEntry.y.count {
                               let currentConf = plotConf24Bit[i]
                               var currentChartDataEntries: [ChartDataEntry] = []
                               plot24BitEntries.forEach { plotEntry in
                                   currentChartDataEntries.append(ChartDataEntry(x: Double(plotEntry.x), y: Double(plotEntry.y[i])))
                               }
                               dataSets.append(buildChartDataSet24Bit(dataEntries: currentChartDataEntries, conf: currentConf, sigType: sigType))
                           }
           
                           DispatchQueue.main.async {
                               self.view.medical24View.chart.data = LineChartData(dataSets: dataSets)
                               self.view.medical24View.chart.notifyDataSetChanged()
                           }
                            
                        }
                        
                    } else {
                        for index in 0..<prevMed24Info!.values.value!.count {
                            let currTime = prevMed24Info!.internalTimeStamp.value! + deltaBetweenSample * index - firstInternalTimeStamp24Bit!
                            
                            let plotEntry = PlotEntry( x: UInt64(currTime), y: [Float(prevMed24Info!.values.value![index])])
                            plot24BitEntries.append(plotEntry)
                            
                            var dataSets: [LineChartDataSet] = []
                            
                            for i in 0..<plotEntry.y.count {
                               let currentConf = plotConf24Bit[i]
                               var currentChartDataEntries: [ChartDataEntry] = []
                               plot24BitEntries.forEach { plotEntry in
                                   currentChartDataEntries.append(ChartDataEntry(x: Double(plotEntry.x), y: Double(plotEntry.y[i])))
                               }
                               dataSets.append(buildChartDataSet24Bit(dataEntries: currentChartDataEntries, conf: currentConf, sigType: sigType))
                           }
           
                           DispatchQueue.main.async {
                               self.view.medical24View.chart.data = LineChartData(dataSets: dataSets)
                               self.view.medical24View.chart.notifyDataSetChanged()
                           }
                            
                        }
                    }
                    
                    if plot24BitEntries.count > 1000 {
                        plot24BitEntries.removeFirst(plot24BitEntries.count - 1000)
                    }
                    
                    if let lastElementTime = plot24BitEntries.last?.x {
                        if let safeLastElementTime = Int(exactly: lastElementTime) {
                            let timeLastElementToVisualize = safeLastElementTime - (sigType.displayWindowTimeSecond*1000)
                            plot24BitEntries.removeAll(where: {$0.x < timeLastElementToVisualize})
                        }
                    }
                    
                    //Save the data for draving at next sample
                    prevMed24Info = sample.data
                }
                
            }
        }
    }
    
    private func buildChartDataSet24Bit(dataEntries: [ChartDataEntry], conf: LineConfig, sigType: MedicalSignalType) -> LineChartDataSet {
        let line = LineChartDataSet(entries: dataEntries, label: conf.name)
        
        if sigType.cubicInterpolation {
            line.mode = .cubicBezier
            line.cubicIntensity = 0.2
        }
        line.drawCirclesEnabled = false
        line.drawIconsEnabled = false
        line.drawValuesEnabled = false
        line.setDrawHighlightIndicators(false)
        line.lineWidth = 1.0
        line.setColor(conf.color)
        line.mode = .linear
        view.medical24View.chart.leftAxis.forceLabelsEnabled = true
        return line
    }
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature) {
        if let pnplFeature = feature as? PnPLFeature {
            guard let sample = pnplFeature.sample,
                  let response = sample.data?.response,
                  let device = response.devices.first else { return }
            
                if let rawPnPLControlledFeature = featuresRawControlled as? RawPnPLControlledFeature {
                    rawPnPLControlledFeature.decodePnPLBoardResponseStreams(components: device.components)
                }
        }
    }
    
    func updateFeatureValueRawPnPLControlled(with sample: AnyFeatureSample?, and feature: Feature) {
        var sampleDesc = ""
        
        if let rawPnplFeature = feature as? RawPnPLControlledFeature {
            if let sample = rawPnplFeature.sample {
                let rawPnPLEntries = rawPnplFeature.extractBleStreamInfo(sample: sample)
                
                for entry in rawPnPLEntries {
                    
                    if let enumLabel = entry.value.first as? RawPnPLEnumLabel {
                        sampleDesc += "\(entry.name) [\(enumLabel.label): \(enumLabel.value)] "
                    } else {
                        if entry.channels == 1 {
                            if entry.multiplyFactor != nil {
                                sampleDesc += "\(entry.name) [\(entry.valueFloat)] "
                            } else {
                                sampleDesc += "\(entry.name) [\(entry.value)] "
                            }
                        } else {
                            if entry.multiplyFactor != nil {
                                sampleDesc += "\(entry.name) [\(entry.valueFloat.splitByChunk(entry.channels!))] "
                            } else {
                                sampleDesc += "\(entry.name) [\(entry.value.splitByChunk(entry.channels!))] "
                            }
                        }
                    }
                    if let unit = entry.unit {
                        sampleDesc += "\(unit) "
                    }
                    if let min = entry.min {
                        sampleDesc += "{min = \(min)} "
                    }
                    if let max = entry.max {
                        sampleDesc += "{max = \(max)} "
                    }
                    sampleDesc += "\n"
                }
                
                
            }
        }
        
        if sampleDesc.isEmpty {
            self.view.syntheticTextView.text = "\(sample?.description ?? "")"
        } else {
            self.view.syntheticTextView.text = "\(sampleDesc)"
        }
    }
    
    func startStop16BitPlotting() {
        if plot16BitStatus == .idle {
            if let feature = view.feature16Bit {
                resetChart16Bit()
                BlueManager.shared.enableNotifications(for: param.node, feature: feature)
                Buttonlayout.standardWithImage(image: ImageLayout.Common.stopFilled).apply(to: self.view.plot16BitStartStopButton, text: "Stop Med16")
                plot16BitStatus = .plotting
            }
        } else {
            if let feature = view.feature16Bit {
                BlueManager.shared.disableNotifications(for: param.node, feature: feature)
                plot16BitStatus = .idle
                firstInternalTimeStamp16Bit = nil
                Buttonlayout.standardWithImage(image: ImageLayout.Common.playFilled).apply(to: self.view.plot16BitStartStopButton, text: "Start Med16")
                prevMed16Info = nil
                plotConf16Bit = []
            }
        }
    }
    
    private func resetChart16Bit() {
        plot16BitEntries = []
        self.view.medical16View.chart.lineData?.dataSets.removeAll()
        self.view.medical16View.chart.notifyDataSetChanged()
        self.view.medical16View.yAxisTitleLabel.text = ""
    }
    
    func startStop24BitPlotting() {
        if plot24BitStatus == .idle {
            if let feature = view.feature24Bit {
                resetChart24Bit()
                BlueManager.shared.enableNotifications(for: param.node, feature: feature)
                Buttonlayout.standardWithImage(image: ImageLayout.Common.stopFilled).apply(to: self.view.plot24BitStartStopButton, text: "Stop Med24")
                plot24BitStatus = .plotting
            }
        } else {
            if let feature = view.feature24Bit {
                BlueManager.shared.disableNotifications(for: param.node, feature: feature)
                plot24BitStatus = .idle
                Buttonlayout.standardWithImage(image: ImageLayout.Common.playFilled).apply(to: self.view.plot24BitStartStopButton, text: "Start Med24")
                firstInternalTimeStamp24Bit = nil
                prevMed24Info = nil
                plotConf24Bit = []
            }
        }
    }
    
    private func resetChart24Bit() {
        plot24BitEntries = []
        self.view.medical24View.chart.lineData?.dataSets.removeAll()
        self.view.medical24View.chart.notifyDataSetChanged()
        self.view.medical24View.yAxisTitleLabel.text = ""
    }
    
    func resetChartsZoom() {
        
        plot16BitEntries = []
        plot24BitEntries = []
        
        self.view.medical24View.chart.lineData?.dataSets.removeAll()
        self.view.medical24View.chart.notifyDataSetChanged()
        self.view.medical24View.yAxisTitleLabel.text = ""
        firstInternalTimeStamp24Bit = nil
        prevMed24Info = nil
        
        self.view.medical16View.chart.lineData?.dataSets.removeAll()
        self.view.medical16View.chart.notifyDataSetChanged()
        self.view.medical16View.yAxisTitleLabel.text = ""
        firstInternalTimeStamp16Bit = nil
        prevMed16Info = nil
        
        self.view.medical16View.resetZoom()
        self.view.medical24View.resetZoom()
    }
}
